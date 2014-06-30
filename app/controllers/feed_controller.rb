class FeedController < ApiController
  PUBLIC_ACTIONS << def index
    # HACK: Sorting by `created_at` because mfk's Morsels were all created in sequence and now needed to be 'randomized'
    if current_user.present?
      custom_respond_with FeedItem.visible
                                  .personalized_for(current_user.id)
                                  .since(params[:since_id])
                                  .max(params[:max_id])
                                  .limit(pagination_count)
                                  .order('created_at DESC')
    else
      custom_respond_with FeedItem.visible
                                  .featured
                                  .since(params[:since_id])
                                  .max(params[:max_id])
                                  .limit(pagination_count)
                                  .order('created_at DESC')
    end
  end
end
