class CollectionsController < ApiController
  def create
    collection = current_user.collections.create(CollectionParams.build(params))

    if collection.valid?
      custom_respond_with collection
    else
      render_json_errors collection.errors
    end
  end

  def update
    collection = Collection.find(params[:id])
    authorize_action_for collection

    if collection.update(CollectionParams.build(params))
      custom_respond_with collection
    else
      render_json_errors collection.errors
    end
  end

  def destroy
    collection = Collection.find(params[:id])
    authorize_action_for collection

    if collection.destroy
      render_json_ok
    else
      render_json_errors(collection.errors)
    end
  end

  class CollectionParams
    def self.build(params, _scope = nil)
      params.require(:collection).permit(:title, :description, :place_id)
    end
  end

  private

  authorize_actions_for Collection, except: PUBLIC_ACTIONS
end
