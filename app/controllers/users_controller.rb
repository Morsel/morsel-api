class UsersController < ApiController
  include PresignedPhotoUploadable

  public_actions << def search
    service = Search::SearchUsers.call(UserParams.build(params).merge(pagination_params))
    custom_respond_with_service service, each_serializer: SlimFollowedUserSerializer
  end

  public_actions << def show
    user = User.find_by_id_or_username(params[:id] || params[:username])
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active?

    custom_respond_with user
  end

  def update
    user = User.find(params[:id])
    authorize_action_for user

    user_params = UserParams.build(params)
    user_params.delete(:promoted) # delete the `promoted` flag since that should only be set via /admin

    if user_params[:photo_key]
      handle_photo_key(user_params[:photo_key], user, serializer: UserWithPrivateAttributesSerializer)
    else
      if password_required?(user, user_params)
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

  public_actions << def validate_email
    user = User.new(email: params[:email])
    user.validate_email

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  public_actions << def validate_username
    user = User.new(username: params[:username])
    user.validate_username

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  public_actions << def reserveusername
    user = User.new(UserParams.build(params))
    user.password = Devise.friendly_token
    user.password_set = false
    user.active = false

    if user.save
      queue_user_event(:reserved_username, user.id)
      EmailUserDecorator.new(user).send_reserved_username_email
      sign_in user, store: false
      render_json(user_id: "#{user.id}")
    else
      render_json_errors user.errors
    end
  end

  public_actions << def updateindustry
    user = User.find(params[:id])

    if user.update(industry: UserParams.build(params)[:industry])
      render_json_ok
    else
      render_json_errors(user.errors)
    end
  end

  public_actions << def forgot_password
    user = User.find_by User.arel_table[:email].lower.eq(params.fetch(:email).downcase)
    EmailUserDecorator.new(user).send_forgot_password_email if user
    render_json('Sending reset password email.')
  end

  public_actions << def reset_password
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, params.fetch(:reset_password_token))
    user = User.find_by reset_password_token: reset_password_token
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active? || !user.reset_password_period_valid?

    # Password confirmation is done client-side, so just pass the password again as the password_confirmation
    if user.reset_password!(params.fetch(:password), params.fetch(:password))
      # TODO: HACK: This is so the reserved username instructions flow can have the authentication token to update the user
      if params[:reserved_username]
        custom_respond_with user, serializer: UserWithAuthTokenSerializer
      else
        render_json_ok
      end
    else
      render_json_errors(user.errors)
    end
  end

  public_actions << def unsubscribe
    user = User.find_by User.arel_table[:email].lower.eq(params.fetch(:email).downcase)

    if user.update(unsubscribed: true)
      render_json_ok
    else
      render_json_errors(user.errors)
    end
  end

  public_actions << def followables
    followable_type = params.fetch(:type)

    # HACK: Support for older clients that don't yet support before_/after_date
    if pagination_params.include? :max_id
      pagination_key = :id
    else
      pagination_key = :created_at
    end

    if followable_type == 'Keyword'
      custom_respond_with Keyword.followed_by(params[:id])
                            .paginate(pagination_params, pagination_key, Follow),
                          each_serializer: FollowedKeywordSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }

    elsif followable_type == 'User'
      custom_respond_with User.followed_by(params[:id])
                            .paginate(pagination_params, pagination_key, Follow),
                          each_serializer: SlimFollowedUserSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }
    end
  end

  public_actions << def likeables
    likeable_type = params.fetch(:type)

    if likeable_type == 'Item'
      custom_respond_with_cached_serializer(
        Item.includes(:creator, :morsel).liked_by(params[:id])
            .paginate(pagination_params)
            .order(Like.arel_table[:id].desc),
        LikedItemSerializer,
        liker_id: params[:id],
        likeable_type: likeable_type
      )
    elsif likeable_type == 'Morsel'
      custom_respond_with_cached_serializer(
        Morsel.includes(:creator).liked_by(params[:id])
              .paginate(pagination_params)
              .order(Like.arel_table[:id].desc),
        LikedMorselSerializer,
        liker_id: params[:id],
        likeable_type: likeable_type
      )
    end
  end

  public_actions << def places
    custom_respond_with Place.joins(:employments)
                            .paginate(pagination_params, :id, Employment)
                            .where(employments: { user_id: params[:id] })
                            .order(Employment.arel_table[:id].desc)
                            .select('places.*, employments.title'),
                        each_serializer: SlimPlaceWithTitleSerializer
  end

  class UserParams
    def self.build(params, _scope = nil)
      params.require(:user).permit(:email, :username, :password, :current_password,
                                   :first_name, :last_name, :bio, :industry,
                                   :photo, :remote_photo_url, :promoted, :query,
                                   :professional, :photo_key, settings: [:auto_follow])
    end
  end

  private

  def password_required?(user, user_params)
    current_password = user_params.delete(:current_password)

    if current_password.nil?
      user.errors.add(:current_password, 'is required to change email') if user_params[:email].present? && user.email != user_params[:email]
      user.errors.add(:current_password, 'is required to change username') if user_params[:username].present? && user.username != user_params[:username]
      user.errors.add(:current_password, 'is required to change password') if user_params[:password].present?
    else
      user.errors.add(:current_password, 'is invalid') unless user.valid_password?(current_password)
    end

    user.errors.count > 0
  end

  authorize_actions_for User, except: public_actions, actions: { me: :read, search: :read, places: :read }
end
