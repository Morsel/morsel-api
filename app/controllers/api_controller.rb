class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  responders :json
  respond_to :json

  before_filter :authenticate_user_from_token!,
                :default_format_json
  include JSONEnvelopable
  include UserEventCreator
  include PaperTrailable

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

  def current_or_null_user
    current_user || User.new
  end

  def default_format_json
    request.format = 'json' unless params[:format]
  end

  private

  class_attribute :public_actions

  def self.public_actions
    @public_actions ||= []
  end

  # api_key is expected to be in the format: "#{identifier}:#{user.authentication_token}"
  # where identifier can be a User ID or a unique string for an external service that communicates w/ the API.
  def authenticate_user_from_token!
    if params[:api_key].present?
      split_key = params[:api_key].split(':')
      if split_key.size == 2
        if (split_key[0] =~ /\A[+-]?\d+\z/).present?
          authenticate_and_sign_in_as_user(split_key[0], split_key[1])
        else
          authenticate_and_sign_in_as_non_user(split_key[0], split_key[1])
        end
      else
        unauthorized_token
      end
    elsif self.public_actions.map(&:to_s).exclude? params[:action]
      unauthorized_token
    end
  rescue ActiveRecord::RecordNotFound
    unauthorized_token
  end

  def authenticate_and_sign_in_as_user(identifier, authentication_token)
    user = User.find(identifier)

    if user && Devise.secure_compare(user.authentication_token, authentication_token)
      sign_in user, store: false, bypass: true
    else
      unauthorized_token
    end
  end

  def authenticate_and_sign_in_as_non_user(identifier, authentication_token)
    # Check if identifier exists in settings
    token = Settings.authentication_tokens[identifier]
    if token && Devise.secure_compare(token, authentication_token)
      # Pass
    else
      unauthorized_token
    end
  end

  def foursquare_api_error
    render_json_errors({ api: ['unable to process Foursquare request'] }, :unprocessable_entity)
  end

  def pagination_params
    @pagination_params ||= begin
      pagination_params = params.slice(:max_id, :since_id, :before_date, :before_id, :after_date, :after_id, :page, :count)
      pagination_params[:count] = pagination_count
      pagination_params
    end
  end

  def pagination_count
    (params[:count].to_i > 20) ? 20 : (params[:count] || Settings.pagination_default_count || 20)
  end

  def record_not_found
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
