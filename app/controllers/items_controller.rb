class ItemsController < ApiController
  include PresignedPhotoUploadable

  def create
    Authority.enforce :create, Item, current_user

    item = current_user.items.build(ItemParams.build(params))

    if item.save
      if params[:prepare_presigned_upload] == 'true'
        handle_presigned_upload(item)
      else
        custom_respond_with item
      end
    else
      render_json_errors item.errors
    end
  end

  PUBLIC_ACTIONS << def show
    item = Item.find(params[:id])

    if params[:prepare_presigned_upload] == 'true'
      Authority.enforce :update, Item, current_user
      Authority.enforce :update, item, current_user
      handle_presigned_upload(item)
    else
      custom_respond_with item
    end
  end

  def update
    Authority.enforce :update, Item, current_user

    item = Item.find(params[:id])

    Authority.enforce :update, item, current_user

    item_params = ItemParams.build(params)

    if item_params[:photo_key]
      handle_photo_key(item_params[:photo_key], item)
    else
      if item.update(item_params)
        if params[:prepare_presigned_upload] == 'true'
          handle_presigned_upload(item)
        else
          custom_respond_with item
        end
      else
        render_json_errors item.errors
      end
    end
  end

  def destroy
    Authority.enforce :delete, Item, current_user

    item = Item.find(params[:id])
    Authority.enforce :delete, item, current_user

    if item.destroy
      render_json_ok
    else
      render_json_errors(item.errors)
    end
  end

  class ItemParams
    def self.build(params, _scope = nil)
      params.require(:item).permit(:description, :photo, :nonce, :sort_order, :morsel_id, :photo_key, :template_order)
    end
  end
end
