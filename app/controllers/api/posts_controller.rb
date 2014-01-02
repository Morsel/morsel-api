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
end
