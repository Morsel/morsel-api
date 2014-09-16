class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  include JSONEnvelopable
  include UserEventCreator
  include PresignedPhotoUploadable

  def create
    user_params = UsersController::UserParams.build(params)
    user_params.delete(:promoted) # delete the `promoted` flag since that should only be set via /admin

    user = User.new(user_params)

    authentication_errors = []
    authentication = nil
    if params[:authentication].present?
      service = BuildAuthentication.call(AuthenticationsController::AuthenticationParams.build(params).merge(user: user))
      if service.valid?
        authentication = service.response
        user.provider = authentication.provider
        user.uid = authentication.uid
      else
        authentication_errors = service.errors.delete(:uid) if service.errors[:uid].include?('already exists')
        authentication_errors += service.errors.full_messages
      end

      user.password_set = user.password.present?

      # Set a temporary password if none is set
      user.password ||= Devise.friendly_token
    end

    if user.valid? && authentication_errors.empty? && user.save
      create_user_event(:created_account, user.id)

      if authentication && authentication.id.present?
        FetchAndFollowSocialUidsWorker.perform_async({
          user_id: user.id,
          provider: authentication.provider
        })
      end

      if params[:prepare_presigned_upload] == 'true'
        handle_presigned_upload(user, serializer: UserWithAuthTokenSerializer)
      else
        custom_respond_with user, serializer: UserWithAuthTokenSerializer
      end
    else
      user.errors.delete(:authentications)
      authentication_errors.each { |e| user.errors[:authentication] << e }
      warden.custom_failure!
      render_json_errors user.errors
    end
  end
end
