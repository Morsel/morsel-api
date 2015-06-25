class CreateMorselKeywords < ActiveRecord::Migration
  def change
    create_table :morsel_keywords do |t|
      t.string :name

      t.timestamps
    end
  end
end
