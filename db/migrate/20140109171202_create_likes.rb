class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user
      t.references :morsel
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
