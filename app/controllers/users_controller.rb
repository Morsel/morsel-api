class UsersController < ApiController
  PUBLIC_ACTIONS = [:show, :checkusername, :reserveusername, :setrole, :unsubscribe]

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

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                   :first_name, :last_name, :photo, :title, :bio, :industry)
    end
  end
end
