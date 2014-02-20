class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable

  def create
    user = User.new(UsersController::UserParams.build(params))
    if user.save
      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      warden.custom_failure!
      render_json_errors(user.errors)
    end
  end
end
