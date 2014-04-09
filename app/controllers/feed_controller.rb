class FeedController < ApiController
  PUBLIC_ACTIONS = [:index]

  def index
    feed_items = FeedItem.since(params[:since_id])
                  .max(params[:max_id])
                  .visible_items
                  .limit(pagination_count)
                  .order('id DESC')
    custom_respond_with feed_items
  end
end
