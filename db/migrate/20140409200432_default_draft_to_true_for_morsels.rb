class DefaultDraftToTrueForMorsels < ActiveRecord::Migration
  def change
    change_column :morsels, :draft, :boolean, default: true
  end
end
