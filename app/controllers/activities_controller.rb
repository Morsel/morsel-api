class ActivitiesController < ApiController
  def index
    activities = Activity.since(params[:since_id])
                         .max(params[:max_id])
                         .where(creator_id: current_user.id)
                         .limit(pagination_count)
                         .order('id DESC')

    custom_respond_with activities
  end
end
