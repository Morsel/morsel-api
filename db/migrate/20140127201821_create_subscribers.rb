class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :email
      t.string :url
      t.string :source_url
      t.string :role

      t.timestamps
    end
    add_index :subscribers, :email
  end
end
