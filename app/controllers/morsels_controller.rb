class MorselsController < ApiController
  PUBLIC_ACTIONS = [:index, :show]
  authorize_actions_for Morsel, except: PUBLIC_ACTIONS
  authority_actions publish: 'update', drafts: 'read'
  respond_to :json

  def create
    morsel = Morsel.new(MorselParams.build(params))
    morsel.creator = current_user

    if morsel.save
      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  def index
    if params[:user_id_or_username].blank?
      morsels = Morsel.includes(:items, :creator)
                  .published
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .limit(pagination_count)
                  .order('id DESC')
    else
      user = User.find_by_id_or_username(params[:user_id_or_username])
      raise ActiveRecord::RecordNotFound if user.nil?
      morsels = Morsel.includes(:items, :creator)
                  .include_drafts(params[:include_drafts])
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .where('creator_id = ?', user.id)
                  .limit(pagination_count)
                  .order('id DESC')
    end

    custom_respond_with morsels
  end

  def drafts
    morsels = Morsel.includes(:items, :creator)
                  .drafts
                  .since(params[:since_id])
                  .max(params[:max_id])
                  .where('creator_id = ?', current_user.id)
                  .limit(pagination_count)
                  .order('updated_at DESC')

    custom_respond_with morsels
  end

  def show
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
    morsel = Morsel.find params[:morsel_id]
    authorize_action_for morsel

    morsel.draft = false
    morsel.primary_item_id = params[:morsel][:primary_item_id] if params[:morsel] && params[:morsel][:primary_item_id].present?

    if morsel.save
      PublishMorselWorker.perform_async({
        morsel_id: morsel.id,
        user_id: current_user.id,
        post_to_facebook: params[:post_to_facebook],
        post_to_twitter: params[:post_to_twitter]
      })

      custom_respond_with morsel
    else
      render_json_errors morsel.errors
    end
  end

  class MorselParams
    def self.build(params)
      params.require(:morsel).permit(:title, :draft, :primary_item_id)
    end
  end
end
