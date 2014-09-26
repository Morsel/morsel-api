class MorselsController < ApiController
  def create
    morsel = Morsel.create(MorselParams.build(params)) do |m|
      m.creator = current_user
    end

    if morsel.valid?
      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  PUBLIC_ACTIONS << def index
    if morsels_for_params.nil?
      unauthorized_token
    else
      custom_respond_with_cached_serializer(
        morsels_for_params,
        MorselSerializer
      )
    end
  end

  def drafts
    # HACK: Support for older clients that don't yet support before_/after_date
    if pagination_params.include? :max_id
      pagination_key = :id
    else
      pagination_key = :updated_at
    end

    morsels = Morsel.includes(:items, :creator)
                    .drafts
                    .paginate(pagination_params, pagination_key)
                    .where(creator_id: current_user.id)

    custom_respond_with morsels
  end

  PUBLIC_ACTIONS << def show
    custom_respond_with Morsel.includes(:items, :creator).find(params[:id])
  end

  def update
    morsel = Morsel.find params[:id]
    authorize_action_for morsel

    if morsel.update(MorselParams.build(params))
      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  def destroy
    morsel = Morsel.find(params[:id])
    authorize_action_for morsel

    if morsel.destroy
      render_json_ok
    else
      render_json_errors(morsel.errors)
    end
  end

  def publish
    morsel = Morsel.find params[:id]
    authorize_action_for morsel

    service = PublishMorsel.call(
      morsel: morsel,
      morsel_params: (params[:morsel].present? ? MorselParams.build(params) : nil),
      social_params: {
        post_to_facebook: params[:post_to_facebook],
        post_to_twitter: params[:post_to_twitter]
      }
    )

    custom_respond_with_service service
  end

  class MorselParams
    def self.build(params, _scope = nil)
      if _scope && _scope.admin?
        params.require(:morsel).permit(:title, :draft, :primary_item_id, :place_id, :template_id, feed_item_attributes: [:id, :featured])
      else
        params.require(:morsel).permit(:title, :draft, :primary_item_id, :place_id, :template_id)
      end
    end
  end

  private

  def morsels_for_params
    @morsels_for_params ||= begin
      # HACK: Support for older clients that don't yet support before_/after_date
      if pagination_params.include? :max_id
        pagination_key = :id
      else
        pagination_key = :published_at
      end

      if params[:place_id] || params[:user_id] || params[:username]
        user_id = params[:user_id] || if params[:place_id].nil?
          user = User.find_by_id_or_username params[:username]
          raise ActiveRecord::RecordNotFound if user.nil?
          user.id
        end

        Morsel.published
              .paginate(pagination_params, pagination_key)
              .where_creator_id_or_tagged_user_id(user_id)
              .where_place_id(params[:place_id])
      elsif current_user.present?
        Morsel.with_drafts(true)
              .paginate(pagination_params, pagination_key)
              .where_creator_id_or_tagged_user_id(current_user.id)
      end
    end
  end

  authorize_actions_for Morsel, except: PUBLIC_ACTIONS, actions: { publish: :update, drafts: :read }
end
