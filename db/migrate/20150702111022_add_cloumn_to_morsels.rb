class AddCloumnToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :news_letter_sent, :boolean,:default => false
  end
end
