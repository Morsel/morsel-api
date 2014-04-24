module ControllerCommentable
  extend ActiveSupport::Concern

  def comment
    Authority.enforce :create, Comment, current_user

    comment = Comment.new({commentable_id: params[:id], commentable_type: model_name, commenter_id: current_user.id}.merge(CommentParams.build(params)))

    if comment.save
      custom_respond_with comment
    else
      render_json_errors comment.errors
    end
  end

  def uncomment
    Authority.enforce :delete, Comment, current_user

    comment = Comment.find_by(id: params[:comment_id])
    if comment
      Authority.enforce :delete, comment, current_user

      if comment.destroy
        custom_respond_with 'OK'
      else
        render_json_errors comment.errors
      end
    end
  end

  def comments
    # Public call, don't bother checking for security violations
    # TODO: Add to PUBLIC_ACTIONS
    custom_respond_with Comment.since(params[:since_id])
                        .max(params[:max_id])
                        .where('commentable_type = ? AND commentable_id = ?', model_name, params[:id])
                        .limit(pagination_count)
                        .order('id DESC')
  end

  private

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end

  def model_name
    controller_name.classify
  end
end
