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
                  .include_drafts(params[:include_drafts])
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .where('creator_id = ?', user.id)
                  .limit(pagination_count)
                  .order('id DESC')
    end

    custom_respond_with posts
  end

  def create
    create_post = CreatePost.run(
      params: PostParams.build(params),
      user: current_user
    )

    if create_post.valid?
      custom_respond_with create_post.result
    else
      render_json_errors create_post.errors
    end
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

  def destroy
    destroy_post = DestroyPost.run(
      post: Post.find(params[:id]),
      user: current_user
    )

    if destroy_post.valid?
      render_json 'OK'
    else
      render_json_errors(destroy_post.errors)
    end
  end

  def append
    morsel = Morsel.find(params[:morsel_id])

    post = Post.includes(:morsel_posts, :morsels, :creator).find(params[:id])
    if post.morsels.include? morsel
      # Already exists
      render_json_errors({ relationship: ['already exists'] }, :bad_request)
    else
      morsel_post = MorselPost.create(morsel: morsel, post: post, sort_order: params[:sort_order].presence)

      if morsel_post.valid?
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
