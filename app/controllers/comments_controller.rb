class CommentsController < ApiController
  public_actions << def create
    if current_user
      comment = Comment.new({ commentable_id: params[:id], commentable_type: commentable_type, commenter_id: current_user.id }.merge(CommentParams.build(params)))
    else
      comment = Comment.new({ commentable_id: params[:id], commentable_type: commentable_type, commenter_id: 0 }.merge(CommentParams.build(params)))
    end

    if comment.save
      custom_respond_with comment
    else
      render_json_errors comment.errors
    end

  end

  public_actions << def index
    if current_user
      custom_respond_with Comment.includes(:commenter)
                               .paginate(pagination_params)
                               .where(commentable_type: commentable_type, commentable_id: params[:id])
                               .order(Comment.arel_table[:id].desc)
    else

      custom_respond_with Comment.where(commentable_type: commentable_type, commentable_id: params[:id])
                               .order(Comment.arel_table[:id].desc)
    end
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

  authorize_actions_for Comment, except: public_actions

  def commentable_type
    request.path.split('/').second.classify
  end

  class CommentParams
    def self.build(params, _scope = nil)
      params.require(:comment).permit(:description)
    end
  end
end
