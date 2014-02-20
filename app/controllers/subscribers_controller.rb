class SubscribersController < ApiController
  respond_to :json
  skip_before_filter :authenticate_user_from_token!

  def create
    subscriber = Subscriber.create(SubscriberParams.build(params))

    if subscriber.persisted?
      render json: 'OK', status: :ok
    else
      render_json_errors(subscriber.errors)
    end
  end

  class SubscriberParams
    def self.build(params)
      params.require(:subscriber).permit(:email, :url, :source_url, :role, :user_id)
    end
  end
end
