class CreateMorsels < ActiveRecord::Migration
  def change
    create_table :morsels do |t|
      t.text :description
      t.integer  :like_count, :default => 0, :null => false

      t.timestamps
    end
  end
end
