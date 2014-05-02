class ActivitiesController < ApiController
  def index
    custom_respond_with Activity.since(params[:since_id])
                                .max(params[:max_id])
                                .where(creator_id: current_user.id)
                                .limit(pagination_count)
                                .order('id DESC')
  end
end
