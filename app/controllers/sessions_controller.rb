class SessionsController < Devise::SessionsController
  include JSONEnvelopable
  prepend_before_filter :require_no_authentication, only: [:create]

  respond_to :json

  def create
    if params[:user].present?
      return sign_in_with_login_and_password((params[:user][:email] || params[:user][:username] || params[:user][:login]), params[:user][:password])
    elsif params[:authentication].present?
      return sign_in_with_authentication(AuthenticationsController::AuthenticationParams.build(params))
    else
      invalid_login_attempt(:unprocessable_entity)
    end
  end

  private

  def sign_in_with_login_and_password(login, password)
    user = User.find_first_by_auth_conditions(login: login)
    return invalid_login_attempt unless user

    if user.valid_password?(password) && user.active?
      if request.format == :html
        sign_in user
        respond_with user, location: after_sign_in_path_for(user)
      else
        sign_in user, store: false
        custom_respond_with(user, serializer: UserWithAuthTokenSerializer)
      end
    else
      invalid_login_attempt
    end
  end

  def sign_in_with_authentication(authentication_params)
    authentication = Authentication.find_by(provider: authentication_params[:provider], uid: authentication_params[:uid])
    return invalid_login_attempt unless authentication && authentication.user

    authentication.token = authentication_params[:token]
    authentication.secret = authentication_params[:secret]
    authentication.short_lived = authentication_params[:short_lived]

    return invalid_login_attempt unless ValidateAuthentication.call(authentication: authentication).valid?

    authentication.exchange_access_token

    if authentication.save
      sign_in authentication.user, store: false
      custom_respond_with authentication.user, serializer: UserWithAuthTokenSerializer
    else
      render_json_errors(authentication.errors)
    end
  end

  def invalid_login_attempt(http_status = :unauthorized)
    if request.format == :html
      render(text: 'login or password is invalid')
    else
      render_json_errors({ base: ['login or password is invalid'] }, http_status)
    end
  end
end
