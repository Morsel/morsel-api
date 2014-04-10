class LikesController < ApiController
  respond_to :json
  authorize_actions_for Like

  def create
    like = Like.find_by(item_id: params[:item_id], user_id: current_user.id)

    render_json_errors({item: ['already liked'] }) && return if like

    like = Like.new(item_id: params[:item_id], user_id: current_user.id)

    if like.save
      custom_respond_with like
    else
      render_json_errors like.errors
    end
  end

  def destroy
    like = Like.find_by(item_id: params[:item_id], user_id: current_user.id)
    render_json_errors({ item: ['not liked'] }) && return unless like
    authorize_action_for like

    if like.destroy
      render_json 'OK'
    else
      render_json_errors like.errors
    end
  end
end
