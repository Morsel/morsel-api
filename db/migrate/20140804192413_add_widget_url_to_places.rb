class AddWidgetUrlToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :widget_url, :string
  end
end
