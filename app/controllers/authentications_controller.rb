class AuthenticationsController < ApiController
  PUBLIC_ACTIONS = [:check]
  authorize_actions_for Authentication, except: PUBLIC_ACTIONS

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

  def destroy
    authentication = Authentication.find(params[:id])
    authorize_action_for authentication

    if authentication.destroy
      render_json 'OK'
    else
      render_json_errors(authentication.errors)
    end
  end

  def check
    authentication_params = AuthenticationParams.build(params)
    count = Authentication.where(provider: authentication_params[:provider], uid: authentication_params[:uid]).count
    render_json(count > 0)
  end

  class AuthenticationParams
    def self.build(params)
      params.require(:authentication).permit(:provider, :uid, :user_id, :token, :secret)
    end
  end
end
