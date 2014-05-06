class SessionsController < Devise::SessionsController
  include JSONEnvelopable
  prepend_before_filter :require_no_authentication, only: [:create]

  respond_to :json

  def create
    if request.format == :html
      super
    else
      if params[:user].present?
        return sign_in_with_login_and_password((params[:user][:email] || params[:user][:username]), params[:user][:password])
      elsif params[:authentication].present?
        return sign_in_with_authentication(AuthenticationsController::AuthenticationParams.build(params[:authentication]))
      else
        invalid_login_attempt(:unprocessable_entity)
      end
    end
  end

  private

  def sign_in_with_login_and_password(login, password)
    user = User.find_for_database_authentication(login: login)
    return invalid_login_attempt unless user

    if user.valid_password?(password)
      sign_in user, store: false

      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      invalid_login_attempt
    end
  end

  def sign_in_with_authentication(authentication_params)
    user = User.joins(:authentications).readonly(false).find_by(authentications: { provider: authentication_params[:provider], token: authentication_params[:token] })
    return invalid_login_attempt unless user

    if authentication_params[:provider] == 'facebook'
      return invalid_login_attempt unless FacebookAuthenticatedUserDecorator.new(user).facebook_valid?
    elsif authentication_params[:provider] == 'twitter'
      return invalid_login_attempt unless TwitterAuthenticatedUserDecorator.new(user).twitter_valid?
    end

    sign_in user, store: false

    custom_respond_with user, serializer: UserWithAuthTokenSerializer
  end

  def invalid_login_attempt(http_status = :unauthorized)
    render_json_errors({ base: ['login or password is invalid'] }, http_status)
  end
end
