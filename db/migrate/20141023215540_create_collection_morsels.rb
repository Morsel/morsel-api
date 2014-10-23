class CreateCollectionMorsels < ActiveRecord::Migration
  def change
    create_table :collection_morsels do |t|
      t.references :collection, index: true
      t.references :morsel, index: true
      t.integer :sort_order

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
