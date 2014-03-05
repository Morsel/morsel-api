class PostsController < ApiController
  PUBLIC_ACTIONS = [:index, :show]
  respond_to :json

  def index
    if params[:user_id_or_username].blank?
      posts = Post.includes(:morsel_posts, :morsels, :creator)
                  .published
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .limit(pagination_count)
                  .order('id DESC')
    else
      user = User.find_by_id_or_username(params[:user_id_or_username])
      raise ActiveRecord::RecordNotFound if user.nil?
      posts = Post.includes(:morsel_posts, :morsels, :creator)
                  .published
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .where('creator_id = ?', user.id)
                  .limit(pagination_count)
                  .order('id DESC')
    end

    custom_respond_with posts
  end

  def show
    custom_respond_with Post.includes(:morsel_posts, :morsels, :creator).find(params[:id])
  end

  def update
    post = Post.includes(:morsel_posts, :morsels, :creator).find(params[:id])

    if post.update_attributes(PostParams.build(params))
      custom_respond_with post
    else
      render_json_errors(post.errors)
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

        custom_respond_with post
      else
        render_json_errors(post.errors)
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
        render_json_errors(post.errors)
      end
    else
      render_json_errors({ relationship: ['not found'] }, :not_found)
    end
  end

  def drafts
    posts = Post.includes(:morsel_posts, :morsels, :creator)
                  .drafts
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .where('creator_id = ?', current_user.id)
                  .limit(pagination_count)
                  .order('updated_at DESC')

    custom_respond_with posts
  end

  class PostParams
    def self.build(params)
      params.require(:post).permit(:title, :draft)
    end
  end
end
