class ChangeUsersTypeToIndustry < ActiveRecord::Migration
  def change
    change_column_default :users, :type, nil
    rename_column :users, :type, :industry
  end
end
