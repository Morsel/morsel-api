class AddSubmitColumnToMorsel < ActiveRecord::Migration
  def change
  	add_column :morsels, :is_submit, :boolean,:default => false
  end
end
