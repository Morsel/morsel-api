class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :title
      t.text :description

      t.references :user, index: true
      t.references :place, index: true

      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
