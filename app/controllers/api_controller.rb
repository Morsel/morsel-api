class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate_user_from_token!
  include JSONEnvelopable

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

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

  def record_not_found(error)
    render_json_errors({ record: ['not found']}, :not_found)
  end

  def unauthorized_token
    render_json_errors({ api: ['unauthorized']}, :unauthorized)
  end
end