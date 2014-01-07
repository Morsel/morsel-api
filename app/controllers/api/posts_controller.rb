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

  class PostParams
    def self.build(params)
      params.require(:post).permit(:title)
    end
  end
end
