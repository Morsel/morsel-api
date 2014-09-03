class CommentsController < ApiController
  def create
    comment = Comment.new({ commentable_id: params[:id], commentable_type: commentable_type, commenter_id: current_user.id }.merge(CommentParams.build(params)))

    if comment.save
      custom_respond_with comment
    else
      render_json_errors comment.errors
    end
  end

  PUBLIC_ACTIONS << def index
    custom_respond_with Comment.paginate(pagination_params)
                               .where(commentable_type: commentable_type, commentable_id: params[:id])
                               .order(Comment.arel_table[:id].desc)
  end

  def destroy
    comment = Comment.find_by(id: params[:comment_id])
    record_not_found && return unless comment
    authorize_action_for comment

    if comment.destroy
      render_json_ok
    else
      render_json_errors comment.errors
    end
  end

  private

  authorize_actions_for Comment, except: PUBLIC_ACTIONS

  def commentable_type
    request.path.split('/').second.classify
  end

  class CommentParams
    def self.build(params, scope = nil)
      params.require(:comment).permit(:description)
    end
  end
end
