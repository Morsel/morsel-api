class PostsController < ApiController
  skip_before_filter :authenticate_user_from_token!, only: [:show]
  respond_to :json

  def index
    if params[:user_id_or_username].blank?
      posts = Post.includes(:morsel_posts, :morsels, :creator).where('creator_id > 0')
    else
      user = User.includes(posts: [:morsel_posts, :morsels]).find_by_id_or_username(params[:user_id_or_username])
      raise ActiveRecord::RecordNotFound if user.nil?
      posts = user.posts
    end

    custom_respond_with posts, include_drafts: (params[:include_drafts] == 'true')
  end

  def show
    custom_respond_with Post.includes(:morsel_posts, :morsels, :creator).find(params[:id]), include_drafts: (params[:include_drafts] == 'true')
  end

  def update
    post = Post.includes(:morsel_posts, :morsels, :creator).find(params[:id])

    if post.update_attributes(PostParams.build(params))
      custom_respond_with post, include_drafts: (params[:include_drafts] == 'true')
    else
      render_json_errors(post.errors, :unprocessable_entity)
    end
  end

  def append
    morsel = Morsel.find(params[:morsel_id])

    post = Post.includes(:morsel_posts, :morsels, :creator).find(params[:id])
    if post.morsels.include? morsel
      # Already exists
      render_json_errors({ relationship: ['already exists'] }, :bad_request)
    else
      if post.morsels << morsel
        post.set_sort_order_for_morsel(morsel.id, params[:sort_order]) if params[:sort_order].present?

        custom_respond_with post, include_drafts: (params[:include_drafts] == 'true')
      else
        render_json_errors(post.errors, :unprocessable_entity)
      end
    end
  end

  def unappend
    morsel = Morsel.find(params[:morsel_id])

    post = Post.find(params[:id])
    if post.morsels.include? morsel
      if post.morsels.destroy(morsel)
        render json: 'OK', status: :ok
      else
        render_json_errors(post.errors, :unprocessable_entity)
      end
    else
      render_json_errors({ relationship: ['not found'] }, :not_found)
    end
  end

  class PostParams
    def self.build(params)
      params.require(:post).permit(:title)
    end
  end
end
