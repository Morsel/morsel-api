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
  rescue_from Foursquare2::APIError, with: :foursquare_api_error
  rescue_from Twitter::Error::TooManyRequests, with: :too_many_requests

  rescue_from Authority::SecurityViolation do |error|
    render_json_errors({ api: ["Not authorized to #{error.action} #{error.resource.class}"] }, :forbidden)
  end

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:admin?)
  end

  private

  PUBLIC_ACTIONS ||= []

  # api_key is expected to be in the format: "#{user.id}:#{user.authentication_token}"
  def authenticate_user_from_token!
    api_key = params[:api_key]
    if api_key.present?
      split_key = api_key.split(':')
      if split_key.size == 2
        user = User.find(split_key[0])

        if user && Devise.secure_compare(user.authentication_token, split_key[1])
          sign_in user, store: false, bypass: true
        else
          unauthorized_token
        end
      else
        unauthorized_token
      end
    elsif self.class::PUBLIC_ACTIONS.map(&:to_s).exclude? params[:action]
      unauthorized_token
    end
  rescue ActiveRecord::RecordNotFound
    unauthorized_token
  end

  def foursquare_api_error(error)
    render_json_errors({ api: ['unable to process Foursquare request'] }, :unprocessable_entity)
  end

  def pagination_params
    pagination_params = params.slice(:max_id, :since_id, :count)
    pagination_params[:count] ||= pagination_count
    pagination_params
  end

  def pagination_count
    params[:count] || Settings.pagination_default_count || 20
  end

  def record_not_found(error = nil)
    render_json_errors({ base: ['Record not found'] }, :not_found)
  end

  def parameter_missing(error)
    render_json_errors({ api: [error.message] }, :not_found)
  end

  def too_many_requests
    render_json_errors({ api: ['too many requests'] }, :too_many_requests)
  end

  def unauthorized_token
    render_json_errors({ api: ['unauthorized'] }, :unauthorized)
  end
end
