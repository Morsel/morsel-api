class UsersController < ApiController
  def search
    custom_respond_with Search::SearchUsers.call(UserParams.build(params)), each_serializer: SlimFollowedUserSerializer
  end

  PUBLIC_ACTIONS << :show
  def show
    if params[:id].present?
      user = User.includes(:authentications, :morsels, :items).find params[:id]
    elsif params[:username].present?
      user = User.includes(:authentications, :morsels, :items).find_by('lower(username) = lower(?)', params[:username])
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

    if password_required?(user, params) && !user.valid_password?(current_password)
      render_json_errors(user.errors)
    elsif user.update_attributes(user_params)
      # if password was changed, return the new auth_token
      if user_params[:password].present?
        custom_respond_with user, serializer: UserWithAuthTokenSerializer
      else
        custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
      end
    else
      render_json_errors(user.errors)
    end
  end

  def me
    custom_respond_with current_user, serializer: UserWithPrivateAttributesSerializer
  end

  PUBLIC_ACTIONS << :validate_email
  def validate_email
    user = User.new(email: params[:email])
    user.validate_email

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  PUBLIC_ACTIONS << :validateusername
  def validateusername
    user = User.new(username: params[:username])
    user.validate_username

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

  PUBLIC_ACTIONS << :reserveusername
  def reserveusername
    user = User.new(UserParams.build(params))
    user.password = Devise.friendly_token
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

  PUBLIC_ACTIONS << :updateindustry
  def updateindustry
    user = User.find(params[:id])

    if user.update(industry: UserParams.build(params)[:industry])
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << :forgot_password
  def forgot_password
    user = User.find_by(email: params.fetch(:email))
    EmailUserDecorator.new(user).send_forgot_password_email if user
    render_json('Sending reset password email.')
  end

  PUBLIC_ACTIONS << :reset_password
  def reset_password
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, params.fetch(:reset_password_token))
    user = User.find_by reset_password_token: reset_password_token
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active? || !user.reset_password_period_valid?

    # Password confirmation is done client-side, so just pass the password again as the password_confirmation
    if user.reset_password!(params.fetch(:password), params.fetch(:password))
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << :unsubscribe
  def unsubscribe
    user = User.find_by(email: params[:email])

    if user.update(unsubscribed: true)
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  PUBLIC_ACTIONS << :followables
  def followables
    followable_type = params.fetch(:type)

    if followable_type == 'Keyword'
      custom_respond_with Keyword.joins("LEFT OUTER JOIN follows ON follows.followable_type = 'Keyword' AND follows.followable_id = keywords.id AND follows.deleted_at IS NULL AND keywords.deleted_at IS NULL")
                              .since(params[:since_id], 'keywords')
                              .max(params[:max_id], 'keywords')
                              .where(follows: { follower_id: params[:id] })
                              .limit(pagination_count)
                              .order('follows.id DESC'),
                          each_serializer: FollowedKeywordSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }

    elsif followable_type == 'User'
      custom_respond_with User.joins("LEFT OUTER JOIN follows ON follows.followable_type = 'User' AND follows.followable_id = users.id AND follows.deleted_at IS NULL AND users.deleted_at IS NULL")
                              .since(params[:since_id], 'users')
                              .max(params[:max_id], 'users')
                              .where(follows: { follower_id: params[:id] })
                              .limit(pagination_count)
                              .order('follows.id DESC'),
                          each_serializer: FollowedUserSerializer,
                          context: {
                            follower_id: params[:id],
                            followable_type: followable_type
                          }
    end
  end

  PUBLIC_ACTIONS << :likeables
  def likeables
    likeable_type = params.fetch(:type)
    if likeable_type == 'Item'
      custom_respond_with Item.joins("LEFT OUTER JOIN likes ON likes.likeable_type = 'Item' AND likes.likeable_id = items.id AND likes.deleted_at IS NULL AND items.deleted_at IS NULL")
                              .includes(:creator, :morsel)
                              .since(params[:since_id], 'items')
                              .max(params[:max_id], 'items')
                              .where(likes: { liker_id: params[:id] })
                              .limit(pagination_count)
                              .order('likes.id DESC'),
                          each_serializer: LikedItemSerializer,
                          context: {
                            liker_id: params[:id],
                            likeable_type: likeable_type
                          }
    end
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :current_password,
                                   :first_name, :last_name, :bio, :industry,
                                   :photo, :remote_photo_url, :promoted, :query)
    end
  end

  private

  def password_required?(user, params)
    user.errors.add(:current_password, 'is required to change email') if params[:user][:email].present? && user.email != params[:user][:email]
    user.errors.add(:current_password, 'is required to change username') if params[:user][:username].present? && user.username != params[:user][:username]
    user.errors.add(:current_password, 'is required to change password') if params[:user][:password].present?

    user.errors.count > 0
  end

  authorize_actions_for User, except: PUBLIC_ACTIONS, actions: { me: :read, search: :read }
end
