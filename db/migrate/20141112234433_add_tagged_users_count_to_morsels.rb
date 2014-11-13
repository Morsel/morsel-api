class AddTaggedUsersCountToMorsels < ActiveRecord::Migration
  def change
    add_column :morsels, :tagged_users_count, :integer, null: false, default: 0
    Morsel.reset_column_information
    Morsel.select("morsels.*").joins(:morsel_user_tags).group("morsels.id").having("count(morsel_user_tags.id) > 0").find_each do |m|
      m.update_columns tagged_users_count: MorselUserTag.where(morsel_id: m.id).count
    end
  end
end
