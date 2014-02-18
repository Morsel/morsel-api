class AuthorizationsController < ApiController
  respond_to :json

  def create
    authorization_params = AuthorizationParams.build(params)
    if params[:user_id].blank?
      authorization = Authorization.create_authorization(authorization_params['provider'], current_user,
                                                         authorization_params['token'], authorization_params['secret'])
    else
      authorization = Authorization.create_authorization(authorization_params['provider'], User.find(params[:user_id]),
                                                         authorization_params['token'], authorization_params['secret'])
    end

    custom_respond_with authorization
  end

  def index
    user_id = params[:user_id] || current_user.id
    authorizations = Authorization.since(params[:since_id])
                                  .max(params[:max_id])
                                  .where(user_id: user_id)
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
