class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable
  include UserEventCreator

  def create
    user = User.new(UsersController::UserParams.build(params))

    authentication_errors = []
    if params[:authentication].present?
      authentication = CreateAuthentication.call(AuthenticationsController::AuthenticationParams.build(params).merge({user: user}))

      unless authentication.valid?
        authentication_errors = authentication.errors.delete(:uid) if authentication.errors[:uid].include?('already exists')
        authentication_errors += authentication.errors.full_messages
      end

      # Set a temporary password if none is set
      user.password ||= Devise.friendly_token
    end

    if user.valid? && authentication_errors.empty? && user.save
      create_user_event(:created_account, user.id)
      custom_respond_with user, serializer: UserWithAuthTokenSerializer
    else
      user.errors.delete(:authentications)
      authentication_errors.each { |e| user.errors[:authentication] << e }
      warden.custom_failure!
      render_json_errors user.errors
    end
  end
end
