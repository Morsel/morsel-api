class AuthenticationsController < ApiController
  respond_to :json
  authorize_actions_for Authentication

  def create
    authentication = CreateAuthentication.call(AuthenticationParams.build(params).merge({user: current_user}))
    if authentication.save
      custom_respond_with authentication
    else
      render_json_errors(authentication.errors)
    end
  end

  def index
    custom_respond_with Authentication.since(params[:since_id])
                                     .max(params[:max_id])
                                     .where(user_id: current_user.id)
                                     .limit(pagination_count)
                                     .order('id DESC')
  end

  class AuthenticationParams
    def self.build(params)
      params.fetch(:secret) if params[:provider] == 'twitter'
      params.permit(:provider, :uid, :user_id, :token, :secret)
    end
  end
end
