class Api::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, only: [:create]

  respond_to :json

  def create
    respond_to do |format|
      format.json do
        # build_resource
        user = User.find_for_database_authentication(email: params[:user][:email])
        return invalid_login_attempt unless user

        if user.valid_password?(params[:user][:password])
          sign_in('user', user)
          json_response({ user: user.as_json(auth_token: user.authentication_token) }, 200)
          return
        else
          invalid_login_attempt
        end
      end
    end
  end

  private

  def json_response_with_errors(errors, http_status)
    json_response({ errors: errors.full_messages.map { |e| { msg: e } } }, http_status)
  end

  def json_response(response, http_status = 200)
    render json: {
      meta: {
        status: http_status,
        msg: Rack::Utils::HTTP_STATUS_CODES[http_status]
      },
      response: response
    }
  end

  def invalid_login_attempt
    json_response_with_errors(['Invalid email or password'], 401)
  end
end
