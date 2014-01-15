class Api::PostsController < Api::ApiController
  respond_to :json

  def index
    if params[:user_id].blank?
      @posts = Post.all
    else
      @posts = Post.find_all_by_creator_id params[:user_id]
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @post.update_attributes(PostParams.build(params))
  end

  def append
    morsel = Morsel.find(params[:morsel_id])

    @post = Post.find(params[:id])
    if @post.morsels.include? morsel
      # Already exists
      json_response_with_errors(['Relationship already exists'], :bad_request)
    else
      @post.morsels << morsel
    end

    if params[:sort_order].present?
      morsel.change_sort_order_for_post_id(@post.id, params[:sort_order])
    end
  end

  def unappend
    morsel = Morsel.find(params[:morsel_id])

    post = Post.find(params[:id])
    if post.morsels.include? morsel
      post.morsels.delete(morsel)

      render json: 'OK', status: :ok
    else
      json_response_with_errors(['Relationship not found'], :not_found)
    end
  end

  class PostParams
    def self.build(params)
      params.require(:post).permit(:title)
    end
  end
end
