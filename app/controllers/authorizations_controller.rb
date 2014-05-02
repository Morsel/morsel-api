class AuthorizationsController < ApiController
  respond_to :json
  authorize_actions_for Authorization

  def create
    authorization = CreateAuthorization.call(AuthorizationParams.build(params).merge({user: current_user}))

    if authorization.save
      custom_respond_with authorization
    else
      render_json_errors(authorization.errors)
    end
  end

  def index
    custom_respond_with Authorization.since(params[:since_id])
                                     .max(params[:max_id])
                                     .where(user_id: current_user.id)
                                     .limit(pagination_count)
                                     .order('id DESC')
  end

  class AuthorizationParams
    def self.build(params)
      params.fetch(:secret) if params[:provider] == 'twitter'
      params.permit(:provider, :uid, :user_id, :token, :secret)
    end
  end
end
