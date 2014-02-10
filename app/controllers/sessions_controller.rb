class SessionsController < Devise::SessionsController
  layout 'api'
  include JSONEnvelopable
  prepend_before_filter :require_no_authentication, only: [:create]

  respond_to :json

  def create
    if request.format == :html
      super
    else
      if params[:user].blank?
        invalid_login_attempt(:unprocessable_entity)
      else
        user = User.find_for_database_authentication(email: params[:user][:email])
        return invalid_login_attempt unless user

        if user.valid_password?(params[:user][:password])
          sign_in user, store: false

          custom_respond_with user, serializer: UserWithAuthTokenSerializer
        else
          invalid_login_attempt
        end
      end
    end
  end

  private

  def invalid_login_attempt(http_status = :unauthorized)
    render_json_errors({ 'email or password' => ['is invalid'] }, http_status)
  end
end
