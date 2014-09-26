class RenameMorselTaggedUsersToMorselUserTags < ActiveRecord::Migration
  def change
    rename_table :morsel_tagged_users, :morsel_user_tags
  end
end
