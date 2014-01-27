class AuthorizationsController < ApiController
  respond_to :json

  def create
    authorization_params = AuthorizationParams.build(params)
    @authorization = Authorization.build_authorization(authorization_params['provider'], current_user,
                                                       authorization_params['token'], authorization_params['secret'])
  end

  def index
    @authorizations = current_user.authorizations
  end

  class AuthorizationParams
    def self.build(params)
      params.require(:secret) if params[:provider] == 'twitter'
      params.permit(:provider, :uid, :user_id, :token, :secret)
    end
  end
end
