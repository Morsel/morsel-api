class PostsController < ApiController
  respond_to :json

  def index
    if params[:user_id].blank?
      @posts = Post.all
    else
      @posts = Post.where(creator_id: params[:user_id])
    end
    @include_drafts = params[:include_drafts] == "true" if params[:include_drafts].present?
  end

  def show
    @post = Post.find(params[:id])
    @include_drafts = params[:include_drafts] == "true" if params[:include_drafts].present?
  end

  def update
    @post = Post.find(params[:id])
    @post.update_attributes(PostParams.build(params))
    @include_drafts = params[:include_drafts] == "true" if params[:include_drafts].present?
  end

  def append
    morsel = Morsel.find(params[:morsel_id])

    @post = Post.find(params[:id])
    if @post.morsels.include? morsel
      # Already exists
      render_json_errors({ relationship: ['already exists']}, :bad_request)
    else
      @post.morsels << morsel

      morsel.change_sort_order_for_post_id(@post.id, params[:sort_order]) if params[:sort_order].present?

      @include_drafts = params[:include_drafts] == "true" if params[:include_drafts].present?
    end
  end

  def unappend
    morsel = Morsel.find(params[:morsel_id])

    post = Post.find(params[:id])
    if post.morsels.include? morsel
      post.morsels.delete(morsel)

      render json: 'OK', status: :ok
    else
      render_json_errors({ relationship: ['not found']}, :not_found)
    end
  end

  class PostParams
    def self.build(params)
      params.require(:post).permit(:title)
    end
  end
end
