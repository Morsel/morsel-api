ActiveAdmin.register Item do
  menu false
  actions :index, :show, :edit

  config.clear_sidebar_sections!

  controller do
    def update
      item = Item.find params[:id]
      if item.update(ItemsController::ItemParams.build(params))
        redirect_to(edit_admin_item_path(item), notice: 'Item updated!')
      else
        redirect_to(edit_admin_item_path(item), alert: 'Error updating item, ask Marty for help.')
      end
    end
  end

  index do
    column :id do |item|
      link_to item.id, admin_item_path(item)
    end
    column :description
    column 'Photo' do |item|
      link_to(image_tag(item.photo_url(:_50x50)), item.photo_url, target: :_blank) if item.photo_url
    end
    actions
  end

  show do |item|
    attributes_table do
      row :id
      row :description
      row 'Photo' do
        link_to(image_tag(item.photo_url(:_320x320)), item.photo_url, target: :_blank) if item.photo_url
      end
    end
  end

  form do |f|
    f.inputs 'Item' do
      f.input :description
      f.input :photo, hint: (f.template.image_tag(f.object.photo_url(:_320x320)) if f.object.photo_url)
    end
    f.actions
  end
end
