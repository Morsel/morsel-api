class CreateKeywordsAndTags < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string   :type
      t.string   :name
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :keywords, :type

    create_table :tags do |t|
      t.integer   :tagger_id
      t.integer   :keyword_id
      t.integer   :taggable_id
      t.string    :taggable_type
      t.datetime  :deleted_at
      t.timestamps
    end
    add_index :tags, [:tagger_id, :taggable_id, :keyword_id]
  end
end
