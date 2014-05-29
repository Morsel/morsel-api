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
    if params[:user_id].present? || params[:username].present?
      if params[:user_id].present?
        user = User.find params[:user_id]
      elsif params[:username].present?
        user = User.find_by('lower(username) = lower(?)', params[:username])
      end
      raise ActiveRecord::RecordNotFound if user.nil?
      custom_respond_with Morsel.includes(:items, :creator)
                          .published
                          .since(params[:since_id])
                          .max(params[:max_id])
                          .where(creator_id: user.id)
                          .limit(pagination_count)
                          .order('id DESC')
    elsif current_user.present?
      custom_respond_with Morsel.includes(:items, :creator)
                          .with_drafts(true)
                          .since(params[:since_id])
                          .max(params[:max_id])
                          .where(creator_id: current_user.id)
                          .limit(pagination_count)
                          .order('id DESC')
    else
      unauthorized_token
    end
  end

  def drafts
    morsels = Morsel.includes(:items, :creator)
                    .drafts
                    .since(params[:since_id])
                    .max(params[:max_id])
                    .where(creator_id: current_user.id)
                    .limit(pagination_count)
                    .order('updated_at DESC')

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
      render_json 'OK'
    else
      render_json_errors(morsel.errors)
    end
  end

  def publish
    morsel = Morsel.find params[:id]
    authorize_action_for morsel

    morsel.draft = false
    morsel.primary_item_id = params[:morsel][:primary_item_id] if params[:morsel] && params[:morsel][:primary_item_id].present?

    if morsel.save
      PublishMorselWorker.perform_async(
        morsel_id: morsel.id,
        user_id: current_user.id,
        post_to_facebook: params[:post_to_facebook],
        post_to_twitter: params[:post_to_twitter]
      )

      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:title, :draft, :primary_item_id, :place_id)
    end
  end

  private

  authorize_actions_for Morsel, except: PUBLIC_ACTIONS, actions: { publish: :update, drafts: :read }
end
