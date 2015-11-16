class CreateMorselMorselTopics < ActiveRecord::Migration
  def change
    create_table :morsel_morsel_topics do |t|
      t.integer :morsel_id
      t.integer :morsel_topic_id

      t.timestamps
    end
  end
end
