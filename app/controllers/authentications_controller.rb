class AuthenticationsController < ApiController
  def create
    service = CreateAuthentication.call(AuthenticationParams.build(params).merge(user: current_user))
    custom_respond_with_service service
  end

  def index
    custom_respond_with Authentication.paginate(pagination_params)
                                      .where(user_id: current_user.id)
                                      .order(Authentication.arel_table[:id].desc)
  end

  def show
    authentication = Authentication.find(params[:id])
    authorize_action_for authentication

    custom_respond_with authentication
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
      render_json_ok
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

    # Convert from csv param to array of ids for where()
    # HACK: Older clients still pass in a comma separated string w/ quotes around each uid, so sub out single quotes
    uids = params.fetch(:uids).gsub("'", '').split(',')

    custom_respond_with User.joins(:authentications)
                            .paginate(pagination_params)
                            .where(authentications: { provider: provider, uid: uids })
                            .order(User.arel_table[:id].desc)
  end

  class AuthenticationParams
    def self.build(params, _scope = nil)
      params.require(:authentication).permit(:provider, :uid, :user_id, :token, :secret, :short_lived)
    end
  end

  private

  authorize_actions_for Authentication, except: PUBLIC_ACTIONS, actions: { connections: :read }
end
