class FeedController < ApiController
  PUBLIC_ACTIONS = [:index]

  def index
    feed_items = FeedItem.visible_items
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .limit(pagination_count)
                  .order('id DESC')

    custom_respond_with feed_items
  end
end
