class UsersController < ApiController
  PUBLIC_ACTIONS = [:show, :checkusername, :reserveusername, :setrole, :unsubscribe, :followed_users, :liked_items]

  def me
    custom_respond_with current_user, serializer: UserWithPrivateAttributesSerializer
  end

  def validateusername
    user = User.new(username: params[:username])
    user.validate_username

    if user.errors.empty?
      render_json true
    else
      render_json_errors user.errors
    end
  end

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

  def updateindustry
    user = User.find(params[:id])

    if user.update(industry: UserParams.build(params)[:industry])
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  def show
    if params[:id].present?
      user = User.includes(:authorizations, :morsels, :items).find params[:id]
    elsif params[:username].present?
      user = User.includes(:authorizations, :morsels, :items).find_by('lower(username) = lower(?)', params[:username])
    end
    raise ActiveRecord::RecordNotFound if user.nil? || !user.active?

    custom_respond_with user
  end

  def update
    user = User.find(params[:id])
    authorize_action_for user

    if user.update_attributes(UserParams.build(params))
      custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
    else
      render_json_errors(user.errors)
    end
  end

  def unsubscribe
    user = User.find_by(email: params[:email])

    if user.update(unsubscribed: true)
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  def followed_users
    custom_respond_with User.joins("LEFT OUTER JOIN follows ON follows.followable_type = 'User' AND follows.followable_id = users.id AND follows.deleted_at is NULL AND users.deleted_at is NULL")
                        .where('follows.follower_id = ?', params[:id])
                        .order('follows.id DESC')
  end

  def liked_items
    custom_respond_with Item.joins("LEFT OUTER JOIN likes ON likes.likeable_type = 'Item' AND likes.likeable_id = items.id AND likes.deleted_at is NULL AND items.deleted_at is NULL")
                        .where('likes.liker_id = ?', params[:id])
                        .order('likes.id DESC')
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                   :first_name, :last_name, :photo, :title, :bio, :industry)
    end
  end
end
