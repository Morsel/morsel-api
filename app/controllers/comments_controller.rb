class CommentsController < ApiController
  PUBLIC_ACTIONS = [:index]
  authorize_actions_for Comment, except: PUBLIC_ACTIONS
  respond_to :json

  def create
    item = Item.find(params[:item_id])

    comment = item.comments.build(CommentParams.build(params))
    comment.user = current_user

    if comment.save
      custom_respond_with comment
    else
      render_json_errors(comment.errors)
    end
  end

  def index
    comments = Comment.since(params[:since_id])
                      .max(params[:max_id])
                      .where(item_id: params[:item_id])
                      .limit(pagination_count)
                      .order('id DESC')

    custom_respond_with comments
  end

  def destroy
    comment = Comment.find(params[:id])

    authorize_action_for comment

    if comment.destroy
      render_json 'OK'
    else
      render_json_errors(comment.errors)
    end
  end

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end
end
