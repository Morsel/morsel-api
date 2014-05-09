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
        return sign_in_with_authentication(AuthenticationsController::AuthenticationParams.build(params))
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
    authentication = Authentication.find_by(provider: authentication_params[:provider], uid: authentication_params[:uid])
    return invalid_login_attempt unless authentication && authentication.user

    authentication.token = authentication_params[:token]
    authentication.secret = authentication_params[:secret]

    if authentication_params[:provider] == 'facebook'
      return invalid_login_attempt unless FacebookAuthenticatedUserDecorator.new(authentication.user).facebook_valid?(authentication)
    elsif authentication_params[:provider] == 'twitter'
      return invalid_login_attempt unless TwitterAuthenticatedUserDecorator.new(authentication.user).twitter_valid?(authentication)
    end

    if authentication.save
      sign_in authentication.user, store: false
      custom_respond_with authentication.user, serializer: UserWithAuthTokenSerializer
    else
      render_json_errors(authentication.errors)
    end
  end

  def invalid_login_attempt(http_status = :unauthorized)
    render_json_errors({ base: ['login or password is invalid'] }, http_status)
  end
end
