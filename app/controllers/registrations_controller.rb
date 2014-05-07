class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable
  include UserEventCreator

  def create
    user = User.new(UsersController::UserParams.build(params))

    if params[:authentication].present?
      CreateAuthentication.call(AuthenticationsController::AuthenticationParams.build(params[:authentication]).merge({user: user}))

      # Set a temporary password if none is set
      user.password ||= Devise.friendly_token
    end

    if user.save
      create_user_event(:created_account, user.id)
      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      warden.custom_failure!
      render_json_errors user.errors
    end
  end
end
