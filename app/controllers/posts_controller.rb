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
    if current_user.can_create?(Post)
      post = Post.new(PostParams.build(params))
      post.creator = current_user

      if post.save
        custom_respond_with post
      else
        render_json_errors(post.errors)
      end
    else
      render_json_errors({ user: ['not authorized to create Post']})
    end
  end

  def show
    custom_respond_with Post.includes(:morsels, :creator).find(params[:id])
  end

  def update
    post = Post.find(params[:id])
    if current_user.can_update?(post)
      if post.update(PostParams.build(params))
        custom_respond_with post
      else
        render_json_errors(post.errors)
      end
    else
      render_json_errors({ user: ['not authorized to update Post']})
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
      params.require(:post).permit(:title, :draft, :primary_morsel_id)
    end
  end
end
