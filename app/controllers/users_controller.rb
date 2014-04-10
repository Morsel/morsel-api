class UsersController < ApiController
  skip_before_filter :authenticate_user_from_token!, only: [:show, :checkusername, :reserveusername, :setrole, :unsubscribe]

  def index
    custom_respond_with User.all
  end

  def me
    custom_respond_with current_user, serializer: UserWithPrivateAttributesSerializer
  end

  def checkusername
    username = params[:username]
    if ReservedPaths.non_username_paths.include?(username) || User.where('lower(username) = ?', username.downcase).count > 0
      render_json true
    else
      render_json false
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
    user_params = UserParams.build(params)
    user = User.find_by(user_params[:email])

    if user.update(industry: user_params[:industry])
      render_json 'OK'
    else
      render_json_errors(user.errors)
    end
  end

  def show
    user = User.includes(:authorizations, :morsels, :items).find_by_id_or_username(params[:user_id_or_username])
    raise ActiveRecord::RecordNotFound if user.nil?

    custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
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
