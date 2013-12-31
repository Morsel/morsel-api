class Api::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    # TODO: Refactor into User model
    user = User.new(Api::UsersController::UserParams.build(params))
    if user.save
      json_response({ user: user.as_json(auth_token: user.authentication_token) }, 201)
      return
    else
      warden.custom_failure!
      json_response_with_errors(user.errors, 422)
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
end
