class ItemsController < ApiController
  PUBLIC_ACTIONS = [:index]
  authorize_actions_for Item, except: PUBLIC_ACTIONS
  authority_actions likers: 'read'
  respond_to :json

  def create
    item = Item.new(ItemParams.build(params))
    item.creator = current_user

    if item.save
      custom_respond_with item
    else
      render_json_errors item.errors
    end
  end

  def show
    custom_respond_with Item.find(params[:id])
  end

  def update
    item_params = ItemParams.build(params)
    item = Item.find params[:id]
    authorize_action_for item

    if item.update(item_params)
      custom_respond_with item
    else
      render_json_errors item.errors
    end
  end

  def destroy
    item = Item.find(params[:id])
    authorize_action_for item

    if item.destroy
      render_json 'OK'
    else
      render_json_errors(item.errors)
    end
  end

  def likers
    likers = User.includes(:likes)
                 .where('likes.item_id = ?', params[:item_id])
                 .order('likes.id DESC')
                 .references(:likes)

    custom_respond_with likers
  end

  class ItemParams
    def self.build(params)
      params.require(:item).permit(:description, :photo, :nonce, :sort_order, :morsel_id)
    end
  end
end
