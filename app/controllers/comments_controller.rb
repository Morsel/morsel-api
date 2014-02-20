class CommentsController < ApiController
  skip_before_filter :authenticate_user_from_token!, only: [:index]
  respond_to :json

  def create
    create_comment = CreateComment.run(
      description: CommentParams.build(params)[:description],
      morsel: Morsel.find(params[:morsel_id]),
      user: current_user
    )

    if create_comment.valid?
      custom_respond_with create_comment.result
    else
      render_json_errors(create_comment.errors)
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
    destroy_comment = DestroyComment.run(
      comment: Comment.find(params[:id]),
      user: current_user
    )

    if destroy_comment.valid?
      render json: 'OK', status: :ok
    else
      render_json_errors(destroy_comment.errors)
    end
  end

  class CommentParams
    def self.build(params)
      params.require(:comment).permit(:description)
    end
  end
end
