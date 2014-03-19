class AuthorizationsController < ApiController
  respond_to :json

  def create
    authorization_params = AuthorizationParams.build(params)

    create_authorization = CreateAuthorization.run(
      provider: authorization_params['provider'],
      user: current_user,
      token: authorization_params['token'],
      secret: authorization_params['secret']
    )

    if create_authorization.valid?
      custom_respond_with create_authorization.result
    else
      render_json_errors(create_authorization.errors)
    end
  end

  def index
    authorizations = Authorization.since(params[:since_id])
                                  .max(params[:max_id])
                                  .where(user_id: current_user.id)
                                  .limit(pagination_count)
                                  .order('id DESC')

    custom_respond_with authorizations
  end

  class AuthorizationParams
    def self.build(params)
      params.require(:secret) if params[:provider] == 'twitter'
      params.permit(:provider, :uid, :user_id, :token, :secret)
    end
  end
end
