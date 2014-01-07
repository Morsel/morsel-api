class Api::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, only: [:create]

  respond_to :json

  def create
    if params[:user].blank?
      json_response_with_errors(['Invalid email or password'], :unprocessable_entity)
    else
      @user = User.find_for_database_authentication(email: params[:user][:email])
      return invalid_login_attempt unless @user

      if @user.valid_password?(params[:user][:password])
        sign_in @user, store: false
      else
        invalid_login_attempt
      end
    end
  end

  private

  def json_response_with_errors(errors, http_status)
    render json: { errors: errors.map { |e| { msg: e } } }, status: http_status
  end

  def invalid_login_attempt
    json_response_with_errors(['Invalid email or password'], :unauthorized)
  end
end
