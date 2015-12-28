class AddScheduledToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :schedual_date, :datetime
  end
end
