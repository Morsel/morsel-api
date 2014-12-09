class NotificationsController < ApiController
  def index
    custom_respond_with_cached_serializer(
      Notification.includes(:payload, :user)
                  .paginate(pagination_params)
                  .where(user_id: current_user.id)
                  .order(Notification.arel_table[:id].desc),
      NotificationSerializer
    )
  end

  def mark_read
    if params[:id].present?
      Notification.includes(:payload, :user).unread.where(id: params[:id], user_id: current_user.id).update_all(marked_read_at: DateTime.now)
    else
      max_id = params.fetch(:max_id)
      Notification.includes(:payload, :user).unread.where(user_id: current_user.id).where(Notification.arel_table[:id].lteq(max_id)).update_all(marked_read_at: DateTime.now)
    end

    SendPushNotificationWorker.perform_async(user_id: current_user.id)

    render_json_ok
  end

  def unread_count
    render_json unread_count: Notification.includes(:payload, :user).unread_for_user_id(current_user.id).count
  end

  private

  authorize_actions_for Notification, except: public_actions, actions: { unread_count: :read, mark_read: :update }
end
