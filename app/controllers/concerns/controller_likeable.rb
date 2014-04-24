module ControllerLikeable
  extend ActiveSupport::Concern

  def like
    Authority.enforce :create, Like, current_user

    if Like.find_by(likeable_id: params[:id], likeable_type: model_name, liker_id: current_user.id)
      render_json_errors({"#{model_name.downcase}" => ['already liked'] })
    else
      like = Like.new(likeable_id: params[:id], likeable_type: model_name, liker_id: current_user.id)
      if like.save
        custom_respond_with like
      else
        render_json_errors like.errors
      end
    end
  end

  def unlike
    Authority.enforce :delete, Like, current_user

    like = Like.find_by(likeable_id: params[:id], likeable_type: model_name, liker_id: current_user.id)
    if like
      Authority.enforce :delete, like, current_user

      if like.destroy
        custom_respond_with 'OK'
      else
        render_json_errors like.errors
      end
    else
      render_json_errors({"#{model_name.downcase}" => ['not liked'] })
    end
  end

  def likers
    Authority.enforce :read, Like, current_user

    custom_respond_with User.joins("LEFT OUTER JOIN likes ON likes.likeable_type = '#{model_name}' AND likes.liker_id = users.id")
                        .where('likes.likeable_id = ?', params[:id])
                        .order('likes.id DESC')
  end

  private

  def model_name
    controller_name.classify
  end
end
