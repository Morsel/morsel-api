class CreateFeedItems < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.references :subject, polymorphic: true, index: true
      t.datetime :deleted_at
      t.boolean :visible, default: false

      t.timestamps
    end
  end
end
