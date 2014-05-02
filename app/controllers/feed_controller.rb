class FeedController < ApiController
  PUBLIC_ACTIONS = [:index]

  def index
    custom_respond_with FeedItem.since(params[:since_id])
                                .max(params[:max_id])
                                .visible_items
                                .limit(pagination_count)
                                .order('id DESC')
  end
end
