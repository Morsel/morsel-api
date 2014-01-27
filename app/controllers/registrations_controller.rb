class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    @user = User.new(UsersController::UserParams.build(params))
    unless @user.save
      warden.custom_failure!
      json_response_with_errors(@user.errors.full_messages, :unprocessable_entity)
    end
  end

  private

  def json_response_with_errors(errors, http_status)
    render json: { errors: errors.map { |e| { msg: e } } }, status: http_status
  end
end
