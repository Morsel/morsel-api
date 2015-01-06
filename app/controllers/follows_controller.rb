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
      render_json_ok
    else
      render_json_errors follow.errors
    end
  end

  public_actions << def followers
    # HACK: Support for older clients that don't yet support before_/after_date
    if pagination_params.include? :max_id
      pagination_key = :id
    else
      pagination_key = :created_at
    end
    custom_respond_with User.joins(:followable_follows)
                            .order(Follow.arel_table[:created_at].desc)
                            .paginate(pagination_params, pagination_key, Follow)
                            .where(follows: { followable_id: params[:id], followable_type: followable_type }),
                        each_serializer: SlimFollowedUserSerializer,
                        context: {
                          followable_id: params[:id],
                          followable_type: followable_type
                        }
  end

  private

  authorize_actions_for Follow, except: public_actions, actions: { followers: :read }

  def followable_type
    request.path.split('/').second.classify
  end
end
