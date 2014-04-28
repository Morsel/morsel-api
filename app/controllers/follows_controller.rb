class FollowsController < ApiController
  PUBLIC_ACTIONS = [:followers]
  authorize_actions_for Follow, except: PUBLIC_ACTIONS, actions: { followers: :read, following: :read }

  def create
    if Follow.find_by(followable_id: params[:id], followable_type: followable_type, follower_id: current_user.id)
      render_json_errors({"#{followable_type.downcase}" => ['already followed'] })
    else
      follow = Follow.new(followable_id: params[:id], followable_type: followable_type, follower_id: current_user.id)
      if follow.save
        custom_respond_with follow
      else
        render_json_errors follow.errors
      end
    end
  end

  def destroy
    follow = Follow.find_by(followable_id: params[:id], followable_type: followable_type, follower_id: current_user.id)
    render_json_errors({ "#{followable_type.downcase}" => ['not followed'] }) && return unless follow
    authorize_action_for follow

    if follow.destroy
      render_json 'OK'
    else
      render_json_errors follow.errors
    end
  end

  def followers
    # TODO: Paginate
    custom_respond_with User.joins("LEFT OUTER JOIN follows ON follows.followable_type = '#{followable_type}' AND follows.follower_id = users.id AND follows.deleted_at is NULL AND users.deleted_at is NULL")
                          .where('follows.followable_id = ?', params[:id])
                          .order('follows.id DESC')
  end

  private

  def followable_type
    request.path.split('/').second.classify
  end
end
