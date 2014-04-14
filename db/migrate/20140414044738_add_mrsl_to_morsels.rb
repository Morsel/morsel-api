class AddMrslToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :mrsl, :hstore
  end
end
