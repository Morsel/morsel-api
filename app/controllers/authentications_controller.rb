class AuthenticationsController < ApiController
  def create
    service = CreateAuthentication.call(AuthenticationParams.build(params).merge(user: current_user))
    if service.valid?
      custom_respond_with service.response
    else
      render_json_errors service.errors
    end
  end

  def index
    custom_respond_with Authentication.since(params[:since_id])
                                     .max(params[:max_id])
                                     .where(user_id: current_user.id)
                                     .limit(pagination_count)
                                     .order('id DESC')
  end

  def update
    authentication = Authentication.find(params[:id])
    authorize_action_for authentication

    authentication.attributes = AuthenticationParams.build(params)
    return render_json_errors(authentication: ['is not valid']) unless ValidateAuthentication.call(authentication: authentication).valid?

    if authentication.update(AuthenticationParams.build(params))
      custom_respond_with authentication
    else
      render_json_errors authentication.errors
    end
  end

  def destroy
    authentication = Authentication.find(params[:id])
    authorize_action_for authentication

    if authentication.destroy
      render_json 'OK'
    else
      render_json_errors(authentication.errors)
    end
  end

  PUBLIC_ACTIONS << def check
    authentication_params = AuthenticationParams.build(params)
    count = Authentication.where(provider: authentication_params[:provider], uid: authentication_params[:uid]).count
    render_json(count > 0)
  end

  def connections
    provider = params.fetch(:provider)
    uids = params.fetch(:uids)

    custom_respond_with User.joins(:authentications)
                            .since(params[:since_id])
                            .max(params[:max_id])
                            .where("authentications.provider = ? AND authentications.uid IN (#{uids})", provider)
                            .limit(pagination_count)
                            .order('id DESC')
  end

  class AuthenticationParams
    def self.build(params)
      params.require(:authentication).permit(:provider, :uid, :user_id, :token, :secret, :short_lived)
    end
  end

  private

  authorize_actions_for Authentication, except: PUBLIC_ACTIONS, actions: { connections: :read }
end
