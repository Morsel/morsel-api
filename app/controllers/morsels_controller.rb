class MorselsController < ApiController
  respond_to :json

  # feed
  def index
    morsels = Morsel.feed
                    .since(params[:since_id])
                    .max(params[:max_id])
                    .limit(pagination_count)
                    .order('id DESC')

    custom_respond_with morsels, each_serializer: MorselForFeedSerializer
  end

  def create
    morsel_params = MorselParams.build(params)

    create_morsel = CreateMorsel.run(
      description: morsel_params[:description],
      draft: morsel_params[:draft],
      uploaded_photo_hash: CreateMorselUploadedPhotoHash.hash(morsel_params[:photo]),
      user: current_user,
      post_id: params[:post_id],
      post_title: params[:post_title],
      sort_order: params[:sort_order],
      post_to_facebook: params[:post_to_facebook],
      post_to_twitter: params[:post_to_twitter]
    )

    if create_morsel.valid?
      custom_respond_with create_morsel.result[:morsel], post: create_morsel.result[:post]
    else
      render_json_errors create_morsel.errors
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
              morsel.posts.destroy(post)

              current_user.post_to_facebook(morsel.facebook_message(new_post)) if params[:post_to_facebook]
              current_user.post_to_twitter(morsel.twitter_message(new_post)) if params[:post_to_twitter]

              custom_respond_with morsel, post: new_post, include_drafts: (params[:include_drafts] == 'true')
            else
              render_json_errors(new_post.errors)
            end
          end
        else
          post.set_sort_order_for_morsel(morsel.id, params[:sort_order]) if params[:sort_order].present?

          current_user.post_to_facebook(morsel.facebook_message(post)) if params[:post_to_facebook]
          current_user.post_to_twitter(morsel.twitter_message(post)) if params[:post_to_twitter]

          custom_respond_with morsel, post: post, include_drafts: (params[:include_drafts] == 'true')
        end
      else
        custom_respond_with morsel
      end
    else
      render_json_errors(morsel.errors)
    end
  end

  def destroy
    morsel = Morsel.find(params[:id])
    if morsel.destroy
      render json: 'OK', status: :ok
    else
      render_json_errors(morsel.errors)
    end
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo, :draft)
    end
  end
end
