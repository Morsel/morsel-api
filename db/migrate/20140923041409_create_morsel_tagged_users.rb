class CreateMorselTaggedUsers < ActiveRecord::Migration
  def change
    create_table :morsel_tagged_users do |t|
      t.integer   :morsel_id
      t.integer   :user_id
      t.datetime  :deleted_at
      t.timestamps
    end
    add_index :morsel_tagged_users, [:morsel_id, :user_id]
  end
end
