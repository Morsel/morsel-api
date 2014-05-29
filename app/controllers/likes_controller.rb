class LikesController < ApiController
  def create
    if Like.find_by(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
      render_json_errors("#{likeable_type.downcase}" => ['already liked'])
    else
      like = Like.new(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
      if like.save
        custom_respond_with like
      else
        render_json_errors like.errors
      end
    end
  end

  def destroy
    like = Like.find_by(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
    render_json_errors("#{likeable_type.downcase}" => ['not liked']) && return unless like
    authorize_action_for like

    if like.destroy
      render_json 'OK'
    else
      render_json_errors like.errors
    end
  end

  PUBLIC_ACTIONS << def likers
    custom_respond_with User.joins(:likes)
                            .since(params[:since_id], 'users')
                            .max(params[:max_id], 'users')
                            .where(likes: { likeable_id: params[:id] })
                            .limit(pagination_count)
                            .order('likes.id DESC')
  end

  private

  authorize_actions_for Like, except: PUBLIC_ACTIONS

  def likeable_type
    request.path.split('/').second.classify
  end
end
