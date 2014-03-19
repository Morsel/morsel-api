class PostsController < ApiController
  PUBLIC_ACTIONS = [:index, :show]
  respond_to :json

  def index
    if params[:user_id_or_username].blank?
      posts = Post.includes(:morsels, :creator)
                  .published
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .limit(pagination_count)
                  .order('id DESC')
    else
      user = User.find_by_id_or_username(params[:user_id_or_username])
      raise ActiveRecord::RecordNotFound if user.nil?
      posts = Post.includes(:morsels, :creator)
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
    custom_respond_with Post.includes(:morsels, :creator).find(params[:id])
  end

  def update
    update_post = UpdatePost.run(
      post: Post.find(params[:id]),
      params: PostParams.build(params),
      user: current_user
    )

    if update_post.valid?
      custom_respond_with update_post.result
    else
      render_json_errors update_post.errors
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

  def drafts
    posts = Post.includes(:morsels, :creator)
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
