class FollowsController < ApiController
  def create
    if Follow.find_by(followable_id: params[:id], followable_type: followable_type, follower_id: current_user.id)
      render_json_errors("#{followable_type.underscore}" => ['already followed'])
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
    render_json_errors("#{followable_type.underscore}" => ['not followed']) && return unless follow
    authorize_action_for follow

    if follow.destroy
      render_json 'OK'
    else
      render_json_errors follow.errors
    end
  end

  PUBLIC_ACTIONS << def followers
    custom_respond_with User.joins(:followable_follows)
                            .since(params[:since_id], 'users')
                            .max(params[:max_id], 'users')
                            .where(follows: { followable_id: params[:id], followable_type: followable_type })
                            .limit(pagination_count)
                            .order('follows.id DESC'),
                        each_serializer: SlimFollowedUserSerializer,
                        context: {
                          followable_id: params[:id],
                          followable_type: followable_type
                        }
  end

  private

  authorize_actions_for Follow, except: PUBLIC_ACTIONS, actions: { followers: :read }

  def followable_type
    request.path.split('/').second.classify
  end
end
