class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable
  include PhotoHashable
  include UserEventCreator

  def create
    user_params = UsersController::UserParams.build(params)
    register_user = RegisterUser.run(
      params: user_params,
      uploaded_photo_hash: photo_hash(user_params[:photo])
    )

    if register_user.valid?
      user = register_user.result
      create_user_event(:created_account, user.id)
      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      warden.custom_failure!
      render_json_errors register_user.errors
    end
  end
end
