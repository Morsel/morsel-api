class ItemsController < ApiController
  PUBLIC_ACTIONS = [:show]

  def create
    Authority.enforce :create, Item, current_user

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
    Authority.enforce :update, Item, current_user

    item = Item.find params[:id]

    Authority.enforce :update, item, current_user

    if item.update(ItemParams.build(params))
      custom_respond_with item
    else
      render_json_errors item.errors
    end
  end

  def destroy
    Authority.enforce :delete, Item, current_user

    item = Item.find(params[:id])
    Authority.enforce :delete, item, current_user

    if item.destroy
      render_json 'OK'
    else
      render_json_errors(item.errors)
    end
  end

  class ItemParams
    def self.build(params)
      params.require(:item).permit(:description, :photo, :nonce, :sort_order, :morsel_id)
    end
  end
end
