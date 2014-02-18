class CommentsController < ApiController
  respond_to :json

  def create
    morsel = Morsel.find(params[:morsel_id])
    if morsel.present?
      comment = Comment.new(CommentParams.build(params))

      comment.user = current_user
      comment.morsel = morsel

      if comment.save
        custom_respond_with comment
      else
        render_json_errors(comment.errors, :unprocessable_entity)
      end
    else
      render_json_errors({ morsel: ['not found'] }, :not_found)
    end
  end

  def index
    comments = Comment.since(params[:since_id])
                      .max(params[:max_id])
                      .where(morsel_id: params[:morsel_id])
                      .limit(pagination_count)
                      .order('id DESC')

    custom_respond_with comments
  end

  def destroy
    comment = Comment.find(params[:id])
    if comment.present?
      if current_user.can_delete_comment?(comment)
        if comment.destroy
          render json: 'OK', status: :ok
        else
          render_json_errors(comment.errors, :unprocessable_entity)
        end
      else
        render_json_errors({ api: ['forbidden'] }, :forbidden)
      end
    else
      render_json_errors({ comment: ['not found'] }, :not_found)
    end
  end

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end
end
