class RegistrationsController < Devise::RegistrationsController
  layout 'api'
  respond_to :json
  include JSONEnvelopable

  def create
    @user = User.new(UsersController::UserParams.build(params))
    unless @user.save
      warden.custom_failure!
      render_json_errors(@user.errors, :unprocessable_entity)
    end
  end
end
