class MorselsController < ApiController
  respond_to :json

  def create
    # TODO: Cyclomatic complexity for create is too high
    morsel_params = MorselParams.build(params)

    morsel = current_user.morsels.build(morsel_params)

    if morsel.save
      if params[:post_id].present?
        post = Post.find(params[:post_id])
      else
        # If a post is not specified for this Morsel, create a new one
        post = Post.new
        post.creator = current_user
      end

      post.title = params[:post_title] if params[:post_title].present?

      post.morsels.push(morsel)
      post.set_sort_order_for_morsel(morsel.id, params[:sort_order]) if params[:sort_order].present?
      post.save!

      current_user.delay(queue: 'social').post_to_facebook(morsel.facebook_message(post)) if params[:post_to_facebook]
      current_user.delay(queue: 'social').post_to_twitter(morsel.twitter_message(post)) if params[:post_to_twitter]

      custom_respond_with morsel, post: post
    else
      render_json_errors(morsel.errors, :unprocessable_entity)
    end
  end

  def show
    custom_respond_with Morsel.find(params[:id]), serializer: MorselWithCommentsSerializer
  end

  def update
    morsel = Morsel.find(params[:id])

    if morsel.update_attributes(MorselParams.build(params))
      if params[:post_id].present? && params[:sort_order].present?
        post = Post.find(params[:post_id])
        post.set_sort_order_for_morsel(morsel.id, params[:sort_order])

        custom_respond_with morsel, post: post
      else
        custom_respond_with morsel
      end
    else
      render_json_errors(morsel.errors, :unprocessable_entity)
    end
  end

  def destroy
    morsel = Morsel.find(params[:id])
    if morsel.destroy
      render json: 'OK', status: :ok
    else
      render_json_errors(morsel.errors, :unprocessable_entity)
    end
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo, :draft)
    end
  end
end
