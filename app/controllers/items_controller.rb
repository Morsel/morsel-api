class ItemsController < ApiController
  def create
    Authority.enforce :create, Item, current_user

    item = Item.new(ItemParams.build(params))
    item.creator = current_user

    if item.save
      if params[:prepare_presigned_upload] == 'true'
        handle_presigned_photo(item)
      else
        custom_respond_with item
      end
    else
      render_json_errors item.errors
    end
  end

  PUBLIC_ACTIONS << def show
    custom_respond_with Item.find(params[:id])
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
          handle_presigned_photo(item)
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
    def self.build(params)
      params.require(:item).permit(:description, :photo, :nonce, :sort_order, :morsel_id, :photo_key)
    end
  end

  private

  def handle_photo_key(photo_key, item)
    # "item-photos/some-id/dbb6a58c-photo.jpg"
    photo_identifier = photo_key.split("#{item.id}/")[1]
    ActiveRecord::Base.connection.execute("UPDATE items SET photo=#{ActiveRecord::Base.sanitize(photo_identifier)} WHERE items.id = #{item.id}")
    item.reload
    item.photo.recreate_versions! if item.photo?
    if item.save
      custom_respond_with item
    else
      render_json_errors item.errors
    end
  end

  def handle_presigned_photo(item)
    service = PreparePresignedUpload.call(model: item)
    if service.valid?
      custom_respond_with item, context: { presigned_upload: service.response }
    else
      render_json_errors item.errors
    end
  end
end
