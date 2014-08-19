class FeedController < ApiController
  PUBLIC_ACTIONS << def index
    if current_user.present?
      custom_respond_with_cached_serializer(
        FeedItem.visible
                .personalized_for(current_user.id)
                .paginate(pagination_params)
                .order(FeedItem.arel_table[:id].desc),
        FeedItemSerializer
      )
    else
      custom_respond_with_cached_serializer(
        FeedItem.visible
                .featured
                .paginate(pagination_params)
                .order(FeedItem.arel_table[:id].desc),
        FeedItemSerializer
      )
    end
  end

  def all
    if current_user.staff?
      custom_respond_with_cached_serializer(
        FeedItem.visible
                .paginate(pagination_params)
                .order(FeedItem.arel_table[:id].desc),
        FeedItemSerializer
      )
    else
      unauthorized_token
    end
  end
end
