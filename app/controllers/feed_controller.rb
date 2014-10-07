class FeedController < ApiController
  PUBLIC_ACTIONS << def index
    if current_user.present?
      if params[:next_for_id].present?
        next_feed_item = FeedItem.includes(:subject).find(params[:next_for_id]).order_for_index(FeedItem.includes(:subject).visible.personalized_for(current_user.id)).next(false)
        next_feed_item ? custom_respond_with(next_feed_item) : render_json_nil
      elsif params[:previous_for_id].present?
        previous_feed_item = FeedItem.includes(:subject).find(params[:previous_for_id]).order_for_index(FeedItem.includes(:subject).visible.personalized_for(current_user.id)).previous(false)
        previous_feed_item ? custom_respond_with(previous_feed_item) : render_json_nil
      else
        custom_respond_with_cached_serializer(
          FeedItem.includes(:subject)
                  .visible
                  .personalized_for(current_user.id)
                  .paginate(pagination_params)
                  .order(FeedItem.arel_table[:id].desc),
          FeedItemSerializer
        )
      end
    else
      if params[:next_for_id].present?
        next_feed_item = FeedItem.includes(:subject).find(params[:next_for_id]).order_for_index(FeedItem.includes(:subject).visible.featured).next(false)
        next_feed_item ? custom_respond_with(next_feed_item) : render_json_nil
      elsif params[:previous_for_id].present?
        previous_feed_item = FeedItem.includes(:subject).find(params[:previous_for_id]).order_for_index(FeedItem.includes(:subject).visible.featured).previous(false)
        previous_feed_item ? custom_respond_with(previous_feed_item) : render_json_nil
      else
        custom_respond_with_cached_serializer(
          FeedItem.includes(:subject)
                  .visible
                  .featured
                  .paginate(pagination_params)
                  .order(FeedItem.arel_table[:id].desc),
          FeedItemSerializer
        )
      end
    end
  end

  PUBLIC_ACTIONS << def all
    custom_respond_with_cached_serializer(
      FeedItem.includes(:subject)
              .visible
              .paginate(pagination_params)
              .order(FeedItem.arel_table[:id].desc),
      FeedItemSerializer
    )
  end
end
