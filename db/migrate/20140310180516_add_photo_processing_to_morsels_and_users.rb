class AddPhotoProcessingToMorselsAndUsers < ActiveRecord::Migration
  def change
    add_column :morsels, :photo_processing, :boolean
    add_column :users, :photo_processing, :boolean
  end
end
