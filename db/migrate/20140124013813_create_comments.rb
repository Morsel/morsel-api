class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :morsel

      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :comments, [:user_id, :morsel_id]
  end
end
