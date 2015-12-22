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

  public_actions << def association_requests

      user = User.find(params[:id])

      if params[:approved]
        render_json user.sent_association_requests.approved, each_serializer: AssociationRequestSerializer
      else
        custom_respond_with user.sent_association_requests, each_serializer: AssociationRequestSerializer
      end

  end

  public_actions << def received_association_requests
    user = User.find(params[:id])
    custom_respond_with user.recieved_association_requests, each_serializer: AssociationRequestSerializer
  end

  def allow_association_request
    if association_request_params.present?

      association_request = current_user.recieved_association_requests.find_by_host_id(association_request_params[:request_creator_id])

      if association_request.approve!
        custom_respond_with current_user.recieved_association_requests, each_serializer: AssociationRequestSerializer
      else
        render_json "Invalid params"
      end
    else
      render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end
  end


  def delete_association_request

    if association_request_params.present?

      association_request = current_user.sent_association_requests.find_by_associated_user_id(association_request_params[:associated_user_id]).destroy
      related_morsel = current_user.associated_morsels.find_by_user_id(association_request_params[:associated_user_id]).destroy
      if association_request.present? && related_morsel.present?
        custom_respond_with current_user.sent_association_requests, each_serializer: AssociationRequestSerializer
      else
        render_json "Invalid params"
      end
    else
      render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end
  end


  def create_association_request

      if association_request_params.present?
        host = User.find_by_email_or_username(params[:id])

        if host
          user_for_association = User.find_by_email_or_username(association_request_params[:name_or_email])
        end

        if user_for_association
          if association_request_params[:is_admin]
          association_request = host.sent_association_requests.find_or_create_by(:associated_user => user_for_association,:approved => true )
          else
          association_request = host.sent_association_requests.find_or_create_by(:associated_user => user_for_association )
          end
        end

        if association_request.present?
          custom_respond_with association_request, serializer: AssociationRequestSerializer
        else
          render_json "Invalid user"
        end

    else
        render_json_errors({ api: ["Invalid Parameter To call."] }, :forbidden)
    end
  end

  public_actions << def subscriptions_keywords_morsels
    user = User.find(params[:id])
    # keywords = user.subscribed_keywords.uniq
    keywords = user.morsel_keywords
    custom_respond_with keywords, each_serializer: UnsubscribeMorselSerializer
  end

  def unsubscribe_users_keyword
    user = User.find(params[:id])
    #authorize_action_for user
    user_params = UserParams.build(params)
    subscriptions = user.subscriptions.where(keyword_id: user_params[:keyword_id])
    if(subscriptions.delete_all)
      render_json "deleted"
    else
      render_json_errors(user.errors)
    end
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

  def create_user_profile

     user = User.find(params[:id])
     authorize_action_for user
     unless user.profile.present?
          if user.create_profile(is_active: true)
            render_json user.profile
          else
             render_json_errors({ api: ["Invalid User"] }, :forbidden)
          end
      else
        render_json user.profile
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

  def morsel_subscribe

    if morsel_subscribe_params[:subscribed_morsel_ids].present?
       subscriptions = morsel_subscribe_params[:subscribed_morsel_ids].compact.map(&:to_i) #| current_user.subscribed_morsel_ids.flatten
        subscriptions.each do |morsel_id|

          morsel = Morsel.find(morsel_id)
          morsel_keyword = morsel.morsel_morsel_keywords.map(&:morsel_keyword_id)
          morsel_keyword.each do |keyword|

          current_user.subscriptions.find_or_create_by(creator_id:morsel.creator_id,keyword_id: keyword)
          end
        end
       # current_user.subscribed_morsel_ids= subscriptions
      render_json_ok
    else
      render_json_errors({ api: ["Subscribed morsel ids blank."] }, :forbidden)
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

  public_actions << def check_reset_password_token
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, params.fetch(:reset_password_token))
    user = User.find_by(id: params.fetch(:user_id), reset_password_token: reset_password_token)
    if user.present?
      render_json true
    else
      render_json false
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
                                 .order(Follow.arel_table[:created_at].desc)
                                 .paginate(pagination_params, pagination_key, Follow),
                          each_serializer: FollowedKeywordSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }

    elsif followable_type == 'User'
      custom_respond_with User.followed_by(params[:id])
                              .order(Follow.arel_table[:created_at].desc)
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
            .order(Like.arel_table[:created_at].desc)
            .paginate(pagination_params, :id, Like),
        LikedItemSerializer,
        liker_id: params[:id],
        likeable_type: likeable_type
      )
    elsif likeable_type == 'Morsel'
      custom_respond_with_cached_serializer(
        Morsel.includes(:creator).liked_by(params[:id])
              .order(Like.arel_table[:created_at].desc)
              .paginate(pagination_params, :id, Like),
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
                                   :professional, :photo_key, settings: [:auto_follow],keyword_id:[],
                                   profile_attributes:[
                                    :host_url,:host_logo,:address,:id,:is_active,
                                    :company_name,:street_address,:city,:state,:zip,:preview_text
                                   ]
                                  )
    end
  end

  private


  def morsel_subscribe_params
    params.require(:user).permit(subscribed_morsel_ids: [])
  end

  def association_request_params
    params.require(:association_request_params).permit(:name_or_email, :id, :approved, :request_creator_id, :associated_user_id, :is_admin)
  end

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

  authorize_actions_for User, except: public_actions, actions: { me: :read, search: :read, places: :read ,morsel_subscribe: :create,create_user_profile: :update,create_association_request: :create,allow_association_request: :update,delete_association_request: :delete,unsubscribe_users_keyword: :delete}
end
