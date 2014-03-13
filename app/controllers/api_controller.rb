class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  responders :json
  respond_to :json

  before_filter :authenticate_user_from_token!
  include JSONEnvelopable
  include UserEventCreator

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:admin?)
  end

  private

  PUBLIC_ACTIONS = []

  # api_key is expected to be in the format: "#{user.id}:#{user.authentication_token}"
  def authenticate_user_from_token!
    if params[:api_key].present?
      authenticate_user = AuthenticateUser.run(
        api_key: params[:api_key]
      )

      if authenticate_user.valid?
        sign_in authenticate_user.result, store: false, bypass: true
      else
        unauthorized_token
      end
    elsif PUBLIC_ACTIONS.include? params[:action]
      true
    else
      false
    end
  end

  def pagination_count
    params[:count] || Settings.pagination_default_count || 20
  end

  def record_not_found(error)
    render_json_errors({ record: ['not found'] }, :not_found)
  end

  def parameter_missing(error)
    render_json_errors({ api: error.message }, :not_found)
  end

  def unauthorized_token
    render_json_errors({ api: ['unauthorized'] }, :unauthorized)
  end
end
