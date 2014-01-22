class Api::MorselsController < Api::ApiController
  respond_to :json

  def index
    if params[:user_id].blank?
      @morsels = Morsel.all
    else
      @morsels = Morsel.where(creator_id: params[:user_id])
    end
  end

  def create
    # TODO: Cyclomatic complexity for create is too high
    morsel_params = MorselParams.build(params)

    @morsel = current_user.morsels.build(morsel_params)

    if @morsel.save
      if params[:post_id].present?
        @post = Post.find(params[:post_id])
      else
        # If a post is not specified for this Morsel, create a new one
        @post = Post.new
        @post.creator = current_user
      end

      @post.title = params[:post_title] if params[:post_title].present?

      @post.morsels.push(@morsel)
      @post.save!

      @morsel.change_sort_order_for_post_id(@post.id, params[:sort_order])  if params[:post_id].present? && params[:sort_order].present?

      @fb_post = current_user.post_to_facebook(@morsel.facebook_message(@post)) if params[:post_to_facebook]
      @tweet = current_user.post_to_twitter(@morsel.twitter_message(@post)) if params[:post_to_twitter]
    else
      json_response_with_errors(@morsel.errors.full_messages, :unprocessable_entity)
    end
  end

  def show
    @morsel = Morsel.find(params[:id])
  end

  def update
    @morsel = Morsel.find(params[:id])

    @morsel.update_attributes(MorselParams.build(params))
    if params[:post_id].present? && params[:sort_order].present?
      @post = Post.find(params[:post_id])
      @morsel.change_sort_order_for_post_id(@post.id, params[:sort_order])
    end
  end

  def destroy
    morsel = Morsel.find(params[:id])
    morsel.destroy
    render json: 'OK', status: :ok
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo)
    end
  end
end
