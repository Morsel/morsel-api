class MorselsController < ApiController
  PUBLIC_ACTIONS = [:index]
  respond_to :json

  include PhotoHashable

  def create
    morsel_params = MorselParams.build(params)
    # Handle deprecated post_id, post_title, and sort_order
    morsel_params[:post] = { id: params[:post_id], title: params[:post_title] } if params[:post_id].present?
    morsel_params[:sort_order] = params[:sort_order]  if params[:sort_order].present?

    create_morsel = CreateMorsel.run(
      params: morsel_params,
      uploaded_photo_hash: photo_hash(morsel_params[:photo]),
      user: current_user,
      post_to_facebook: params[:post_to_facebook],
      post_to_twitter: params[:post_to_twitter]
    )

    if create_morsel.valid?
      custom_respond_with create_morsel.result
    else
      render_json_errors create_morsel.errors
    end
  end

  def show
    custom_respond_with Morsel.find(params[:id])
  end

  def update
    morsel_params = MorselParams.build(params)
    # Handle deprecated post_id, post_title, and sort_order
    morsel_params[:post] = { id: params[:post_id], title: params[:post_title] } if params[:post_id].present?
    morsel_params[:sort_order] = params[:sort_order]  if params[:sort_order].present?

    update_morsel = UpdateMorsel.run(
      morsel: Morsel.find(params[:id]),
      params: morsel_params,
      uploaded_photo_hash: photo_hash(morsel_params[:photo]),
      user: current_user,
      post_to_facebook: params[:post_to_facebook],
      post_to_twitter: params[:post_to_twitter]
    )

    if update_morsel.valid?
      custom_respond_with update_morsel.result
    else
      render_json_errors update_morsel.errors
    end
  end

  def destroy
    destroy_morsel = DestroyMorsel.run(
      morsel: Morsel.find(params[:id]),
      user: current_user
    )

    if destroy_morsel.valid?
      render_json 'OK'
    else
      render_json_errors(destroy_morsel.errors)
    end
  end

  def likers
    likers = User.includes(:likes)
                 .where('likes.morsel_id = ?', params[:id])
                 .order('likes.id DESC')
                 .references(:likes)

    custom_respond_with likers
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:description, :photo, :nonce, :sort_order, post: [:id, :title])
    end
  end
end
