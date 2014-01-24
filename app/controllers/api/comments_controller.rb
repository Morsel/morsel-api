class Api::CommentsController < Api::ApiController
  respond_to :json

  def create
    morsel = Morsel.find(params[:morsel_id])
    if morsel.present?
      @comment = Comment.new(CommentParams.build(params))

      @comment.user = current_user
      @comment.morsel = morsel

      @comment.save
    else
      json_response_with_errors(['Morsel not found'], :not_found)
    end
  end

  def index
    morsel = Morsel.find(params[:morsel_id])
    if morsel.present?
      @comments = morsel.comments
    else
      json_response_with_errors(['Morsel not found'], :not_found)
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    if comment
      if comment.user == current_user || comment.morsel.creator == current_user
        comment.destroy
        render json: 'OK', status: :ok
      else
        json_response_with_errors(['Forbidden'], :forbidden)
      end
    else
      json_response_with_errors(['Comment not found'], :not_found)
    end
  end

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end
end
