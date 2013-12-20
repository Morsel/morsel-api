class Api::ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate_user_from_token!

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:admin?)
  end

  private

  # user_token is expected to be in the format: "#{user.id}:#{user.authentication_token}"
  def authenticate_user_from_token!
    # !!!: for now we only auth on user_id exists
    user_id  = params[:user_id].presence
    user = user_id && User.find(user_id)

    if user
      sign_in user, store: false
    else
      unauthorized_token
      return
    end

    # user_token  = params[:user_token].presence
    # split_token = user_token.split(':')
    # unauthorized_token and return unless split_token.length == 2

    # user = user_token && User.find(split_token[0])

    # if user && Devise.secure_compare(user.authentication_token, user_token.split(':')[1])
    #   sign_in user, store: false  # Require token for every request
    # else
    #   unauthorized_token
    #   return
    # end
  end

  def unauthorized_token
    json_response(nil, 401)
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
