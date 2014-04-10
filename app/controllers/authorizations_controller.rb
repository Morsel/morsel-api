class AuthorizationsController < ApiController
  respond_to :json
  authorize_actions_for Authorization

  def create
    authorization_params = AuthorizationParams.build(params)
    provider = authorization_params['provider']
    if provider == 'facebook'
      authorization = FacebookUserDecorator.new(current_user).build_facebook_authorization(authorization_params)
    elsif provider == 'twitter'
      authorization = TwitterUserDecorator.new(current_user).build_twitter_authorization(authorization_params)
    end

    if authorization.save
      custom_respond_with authorization
    else
      render_json_errors(authorization.errors)
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
