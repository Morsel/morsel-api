class SubscribersController < ApiController
  respond_to :json
  skip_before_filter :authenticate_user_from_token!

  def create
    if subscriber = Subscriber.create(SubscriberParams.build(params))
      render json: 'OK', status: :ok
    else
      render_json_errors(subscriber.errors, :unprocessable_entity)
    end
  end

  class SubscriberParams
    def self.build(params)
      params.require(:subscriber).permit(:email, :url, :source_url, :role, :user_id)
    end
  end
end
