class UseridToKeyword < ActiveRecord::Migration
  def change
  		add_column :morsel_keywords, :user_id, :integer
    
  end
end
