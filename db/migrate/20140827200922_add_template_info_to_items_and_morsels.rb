class AddTemplateInfoToItemsAndMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :template_id, :integer
    add_column :items, :template_order, :integer
  end
end
