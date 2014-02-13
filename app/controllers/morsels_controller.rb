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
      if params[:post_id].present?
        post = Post.find(params[:post_id])

        if params[:new_post_id].present?
          new_post = Post.find(params[:new_post_id])
          if new_post.morsels.include? morsel
            # Already exists
            render_json_errors({ relationship: ['already exists'] }, :bad_request)
          else
            if new_post.morsels << morsel
              new_post.set_sort_order_for_morsel(morsel.id, params[:sort_order]) if params[:sort_order].present?

              # Delete the Relationship from the old post
              morsel.morsel_posts.where(post_id: post.id).destroy_all

              custom_respond_with morsel, post: new_post, include_drafts: (params[:include_drafts] == 'true')
            else
              render_json_errors(new_post.errors, :unprocessable_entity)
            end
          end
        else
          # sfasdfa

          post.set_sort_order_for_morsel(morsel.id, params[:sort_order]) if params[:sort_order].present?
          custom_respond_with morsel, post: post, include_drafts: (params[:include_drafts] == 'true')
        end
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
