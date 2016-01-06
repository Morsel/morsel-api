class AddLocalScheduleTimeToMorsel < ActiveRecord::Migration
  def change
    add_column :morsels, :local_schedual_date, :datetime
  end
end
