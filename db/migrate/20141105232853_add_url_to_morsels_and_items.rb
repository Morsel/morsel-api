class AddUrlToMorselsAndItems < ActiveRecord::Migration
  def change
    add_column :morsels, :cached_url , :string
    add_column :items, :cached_url, :string
  end
end
