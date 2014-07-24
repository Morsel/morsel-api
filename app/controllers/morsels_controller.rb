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
    if params[:place_id].present?
      custom_respond_with Morsel.includes(:items, :creator, :place)
                          .published
                          .paginate(pagination_params)
                          .where(place_id: params[:place_id])
                          .order(Morsel.arel_table[:id].desc)
    elsif params[:user_id].present? || params[:username].present?
      if params[:user_id].present?
        user = User.find params[:user_id]
      elsif params[:username].present?
        user = User.find_by(User.arel_table[:username].lower.eq(params[:username].downcase))
      end
      raise ActiveRecord::RecordNotFound if user.nil?
      custom_respond_with Morsel.includes(:items, :creator, :place)
                          .published
                          .paginate(pagination_params)
                          .where(creator_id: user.id)
                          .order(Morsel.arel_table[:id].desc)
    elsif current_user.present?
      custom_respond_with Morsel.includes(:items, :creator, :place)
                          .with_drafts(true)
                          .paginate(pagination_params)
                          .where(creator_id: current_user.id)
                          .order(Morsel.arel_table[:id].desc)
    else
      unauthorized_token
    end
  end

  def drafts
    morsels = Morsel.includes(:items, :creator)
                    .drafts
                    .paginate(pagination_params)
                    .where(creator_id: current_user.id)
                    .order(Morsel.arel_table[:updated_at].desc)

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

    morsel.primary_item_id = params[:morsel][:primary_item_id] if params[:morsel] && params[:morsel][:primary_item_id].present?

    if morsel.publish! params.slice(:post_to_facebook, :post_to_twitter)
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
