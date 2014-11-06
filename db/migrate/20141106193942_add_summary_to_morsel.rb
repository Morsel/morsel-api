class AddSummaryToMorsel < ActiveRecord::Migration
  def change
    add_column :morsels, :summary, :text
  end
end
