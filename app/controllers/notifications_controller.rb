class NotificationsController < ApiController
  def index
    notifications = Notification.since(params[:since_id])
                                .max(params[:max_id])
                                .where(user_id: current_user.id)
                                .limit(pagination_count)
                                .order('id DESC')

    custom_respond_with notifications
  end
end
