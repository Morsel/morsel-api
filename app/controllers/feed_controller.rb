class FeedController < ApiController
  PUBLIC_ACTIONS << def index
    if current_user.present?
      custom_respond_with FeedItem.visible
                                  .personalized_for(current_user.id)
                                  .paginate(pagination_params)
                                  .order(FeedItem.arel_table[:id].desc)
    else
      custom_respond_with FeedItem.visible
                                  .featured
                                  .paginate(pagination_params)
                                  .order(FeedItem.arel_table[:id].desc)
    end
  end
end
