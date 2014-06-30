class FeedController < ApiController
  PUBLIC_ACTIONS << def index
    if current_user.present?
      custom_respond_with FeedItem.visible
                                  .personalized_for(current_user.id)
                                  .since(params[:since_id])
                                  .max(params[:max_id])
                                  .limit(pagination_count)
                                  .order('id DESC')
    else
      custom_respond_with FeedItem.visible
                                  .featured
                                  .since(params[:since_id])
                                  .max(params[:max_id])
                                  .limit(pagination_count)
                                  .order('id DESC')
    end
  end
end
