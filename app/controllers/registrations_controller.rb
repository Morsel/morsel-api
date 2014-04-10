class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable
  include UserEventCreator

  def create
    user = User.new(UsersController::UserParams.build(params))

    if user.save
      create_user_event(:created_account, user.id)
      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      warden.custom_failure!
      render_json_errors user.errors
    end
  end
end
