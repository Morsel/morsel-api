class CreateMorselTopics < ActiveRecord::Migration
  def change
    create_table :morsel_topics do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
  end
end
