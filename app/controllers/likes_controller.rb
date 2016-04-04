class LikesController < ApiController
  public_actions << def create
    if current_user
      if Like.find_by(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
        render_json_errors("#{likeable_type.underscore}" => ['already liked'])
      else
        like = Like.new(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
        if like.save
          custom_respond_with like
        else
          render_json_errors like.errors
        end
      end
    else

      like = Like.new(likeable_id: params[:id], likeable_type: likeable_type, liker_id: 0)
      if like.save
        custom_respond_with like
      else
        render_json_errors like.errors
      end
    end
  end

  def destroy
    like = Like.find_by(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
    render_json_errors("#{likeable_type.underscore}" => ['not liked']) && return unless like
    authorize_action_for like

    if like.destroy
      render_json_ok
    else
      render_json_errors like.errors
    end
  end

  public_actions << def likers
    if current_user
        custom_respond_with User.joins(:likes)
                            .paginate(pagination_params)
                            .where(likes: { likeable_id: params[:id] })
                            .order(Like.arel_table[:id].desc)
    else
      custom_respond_with Like.where(likes: { likeable_id: params[:id] })
    end
  end

  private

  authorize_actions_for Like, except: public_actions

  def likeable_type
    request.path.split('/').second.classify
  end
end
