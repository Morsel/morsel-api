class UsersController < ApiController
  include PresignedPhotoUploadable

  PUBLIC_ACTIONS << def search
    service = Search::SearchUsers.call(UserParams.build(params).merge(pagination_params))
    if service.valid?
      custom_respond_with service.response, each_serializer: SlimFollowedUserSerializer
    else
      render_json_errors service.errors
    end
  end

  PUBLIC_ACTIONS << def show
    if params[:id].present?
      user = User.includes(:authentications, :morsels, :items).find params[:id]
    elsif params[:username].present?
      user = User.includes(:authentications, :morsels, :items).find_by(User.arel_table[:username].lower.eq(params[:username].downcase))
    end
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active?

    custom_respond_with user
  end

  def update
    user = User.find(params[:id])
    authorize_action_for user

    user_params = UserParams.build(params)
    user_params.delete(:promoted) # delete the `promoted` flag since that should only be set via /admin
    current_password = user_params.delete(:current_password)

    if user_params[:photo_key]
      handle_photo_key(user_params[:photo_key], user, serializer: UserWithPrivateAttributesSerializer)
    else
      if password_required?(user, params) && !user.valid_password?(current_password)
        render_json_errors(user.errors)
      elsif user.update_attributes(user_params)
        if params[:prepare_presigned_upload] == 'true'
          handle_presigned_upload(user, serializer: UserWithPrivateAttributesSerializer)
        else
          # if password was changed, return the new auth_token
          if user_params[:password].present?
            custom_respond_with user, serializer: UserWithAuthTokenSerializer
          else
            custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
          end
        end
      else
        render_json_errors(user.errors)
      end
    end
  end

  def me
    if params[:prepare_presigned_upload] == 'true'
      Authority.enforce :update, User, current_user
      Authority.enforce :update, current_user, current_user
      handle_presigned_upload(current_user, serializer: UserWithPrivateAttributesSerializer)
    else
      custom_respond_with current_user, serializer: UserWithPrivateAttributesSerializer
    end
  end

  PUBLIC_ACTIONS << def validate_email
    user = User.new(email: params[:email])
    user.validate_email

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  PUBLIC_ACTIONS << def validate_username
    user = User.new(username: params[:username])
    user.validate_username

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  PUBLIC_ACTIONS << def reserveusername
    user = User.new(UserParams.build(params))
    user.password = Devise.friendly_token
    user.password_set = false
    user.active = false

    if user.save
      create_user_event(:reserved_username, user.id)
      EmailUserDecorator.new(user).send_reserved_username_email
      sign_in user, store: false
      render_json(user_id: "#{user.id}")
    else
      render_json_errors user.errors
    end
  end

  PUBLIC_ACTIONS << def updateindustry
    user = User.find(params[:id])

    if user.update(industry: UserParams.build(params)[:industry])
      render_json_ok
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << def forgot_password
    user = User.find_by(email: params.fetch(:email))
    EmailUserDecorator.new(user).send_forgot_password_email if user
    render_json('Sending reset password email.')
  end

  PUBLIC_ACTIONS << def reset_password
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, params.fetch(:reset_password_token))
    user = User.find_by reset_password_token: reset_password_token
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active? || !user.reset_password_period_valid?

    # Password confirmation is done client-side, so just pass the password again as the password_confirmation
    if user.reset_password!(params.fetch(:password), params.fetch(:password))
      render_json_ok
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << def unsubscribe
    user = User.find_by(email: params[:email])

    if user.update(unsubscribed: true)
      render_json_ok
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << def followables
    followable_type = params.fetch(:type)

    if followable_type == 'Keyword'
      custom_respond_with Keyword.followed_by(params[:id])
                            .paginate(pagination_params, Keyword)
                            .order(Follow.arel_table[:id].desc),
                          each_serializer: FollowedKeywordSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }

    elsif followable_type == 'User'
      custom_respond_with User.followed_by(params[:id])
                              .paginate(pagination_params, User)
                              .order(Follow.arel_table[:id].desc),
                          each_serializer: SlimFollowedUserSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }
    end
  end

  PUBLIC_ACTIONS << def likeables
    likeable_type = params.fetch(:type)
    if likeable_type == 'Item'
      custom_respond_with Item.liked_by(params[:id])
                            .paginate(pagination_params, Item)
                            .order(Like.arel_table[:id].desc),
                          each_serializer: LikedItemSerializer,
                          context: {
                            liker_id: params[:id],
                            likeable_type: likeable_type
                          }
    end
  end

  PUBLIC_ACTIONS << def places
    custom_respond_with Place.joins(:employments)
                            .paginate(pagination_params, Employment)
                            .where(employments: { user_id: params[:id] })
                            .order(Employment.arel_table[:id].desc)
                            .select('places.*, employments.title'),
                        each_serializer: SlimPlaceWithTitleSerializer
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :current_password,
                                   :first_name, :last_name, :bio, :industry,
                                   :photo, :remote_photo_url, :promoted, :query,
                                   :professional, :photo_key, settings: [:auto_follow])
    end
  end

  private

  def password_required?(user, params)
    user.errors.add(:current_password, 'is required to change email') if params[:user][:email].present? && user.email != params[:user][:email]
    user.errors.add(:current_password, 'is required to change username') if params[:user][:username].present? && user.username != params[:user][:username]
    user.errors.add(:current_password, 'is required to change password') if params[:user][:password].present?

    user.errors.count > 0
  end

  authorize_actions_for User, except: PUBLIC_ACTIONS, actions: { me: :read, search: :read, places: :read }
end
