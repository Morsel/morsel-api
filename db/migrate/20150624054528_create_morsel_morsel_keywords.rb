class CreateMorselMorselKeywords < ActiveRecord::Migration
  def change
    create_table :morsel_morsel_keywords do |t|
    	t.integer :morsel_id
    	t.integer :morsel_keyword_id

      	t.timestamps
    end
  end
end
