class NotificationsController < ApiController
  def index
    notifications = Notification.paginate(pagination_params)
                                .where(user_id: current_user.id)
                                .order(Notification.arel_table[:id].desc)

    custom_respond_with notifications
  end

  def mark_read
    if params[:id].present?
      Notification.unread.where(id: params[:id]).update_all(marked_read_at: DateTime.now)
    else
      max_id = params.fetch(:max_id)
      Notification.unread.where(Notification.arel_table[:id].lteq(max_id)).update_all(marked_read_at: DateTime.now)
    end

    render_json_ok
  end

  def unread_count
    render_json unread_count: Notification.unread_for_user_id(current_user.id).count
  end

  private

  authorize_actions_for Notification, actions: { unread_count: :read, mark_read: :update }
end
