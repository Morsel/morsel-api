class Api::ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate_user_from_token!
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:admin?)
  end

  private

  # api_key is expected to be in the format: "#{user.id}:#{user.authentication_token}"
  def authenticate_user_from_token!
    # !!!: for now we only auth on user_id exists
    user_id  = params[:api_key].presence
    user = user_id && User.find(user_id)

    if user
      sign_in user, store: false, bypass: true
    else
      unauthorized_token
      return
    end

    # api_key  = params[:api_key].presence
    # split_token = api_key.split(':')
    # unauthorized_token and return unless split_token.length == 2

    # user = api_key && User.find(split_token[0])

    # if user && Devise.secure_compare(user.authentication_token, api_key.split(':')[1])
    #   sign_in user, store: false  # Require token for every request
    # else
    #   unauthorized_token
    #   return
    # end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With auth_token X-CSRF-Token}.join(',')
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == "OPTIONS"
      headers['Access-Control-Allow-Origin'] = 'http://localhost'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With auth_token X-CSRF-Token}.join(',')
      headers['Access-Control-Max-Age'] = '1728000'
      render text: '', content_type: 'text/plain'
    end
  end

  def json_response_with_errors(errors, http_status)
    render json: { errors: errors.map { |e| { msg: e } } }, status: http_status
  end

  def unauthorized_token
    json_response_with_errors(['Unauthorized'], :unauthorized)
  end
end
