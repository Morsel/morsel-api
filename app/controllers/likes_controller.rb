class LikesController < ApiController
  authorize_actions_for Like, actions: { likers: :read }

  def create
    if Like.find_by(likeable_id: params[:id], likeable_type: likeable_type, liker_id: current_user.id)
      render_json_errors({"#{likeable_type.downcase}" => ['already liked'] })
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
    render_json_errors({ "#{likeable_type.downcase}" => ['not liked'] }) && return unless like
    authorize_action_for like

    if like.destroy
      render_json 'OK'
    else
      render_json_errors like.errors
    end
  end

  def likers
    # TODO: Paginate
    custom_respond_with User.joins("LEFT OUTER JOIN likes ON likes.likeable_type = '#{likeable_type}' AND likes.liker_id = users.id AND likes.deleted_at is NULL AND users.deleted_at is NULL")
                          .where('likes.likeable_id = ?', params[:id])
                          .order('likes.id DESC')
  end

  private

  def likeable_type
    request.path.split('/').second.classify
  end
end
