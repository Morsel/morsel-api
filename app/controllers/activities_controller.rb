class ActivitiesController < ApiController
  def index
    custom_respond_with_cached_serializer(
      Activity.includes(:creator, :action, :subject)
              .paginate(pagination_params)
              .where(creator_id: current_user.id, hidden: false)
              .order(Activity.arel_table[:id].desc),
      ActivitySerializer
    )
  end

  def followables_activities
    custom_respond_with_cached_serializer(
      Activity.includes(:creator, :action, :subject)
              .paginate(pagination_params)
              .where(creator_id: current_user.followed_user_ids, hidden: false)
              .order(Activity.arel_table[:id].desc),
      ActivitySerializer
    )
  end

  private

  authorize_actions_for Activity, actions: { followables_activities: :read }
end
