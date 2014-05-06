class CommentsController < ApiController
  PUBLIC_ACTIONS = [:index]
  authorize_actions_for Comment, except: PUBLIC_ACTIONS

  def create
    comment = Comment.new({commentable_id: params[:id], commentable_type: commentable_type, commenter_id: current_user.id}.merge(CommentParams.build(params)))

    if comment.save
      custom_respond_with comment
    else
      render_json_errors comment.errors
    end
  end

  def index
    custom_respond_with Comment.since(params[:since_id])
                               .max(params[:max_id])
                               .where(commentable_type: commentable_type, commentable_id: params[:id])
                               .limit(pagination_count)
                               .order('id DESC')
  end

  def destroy
    comment = Comment.find_by(id: params[:comment_id])
    if comment
      authorize_action_for comment

      if comment.destroy
        custom_respond_with 'OK'
      else
        render_json_errors comment.errors
      end
    end
  end

  private

  def commentable_type
    request.path.split('/').second.classify
  end

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end
end
