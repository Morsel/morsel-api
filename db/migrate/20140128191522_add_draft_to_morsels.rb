class AddDraftToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :draft, :boolean, default: false, null: false
  end
end
