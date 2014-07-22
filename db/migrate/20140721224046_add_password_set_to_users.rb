class AddPasswordSetToUsers < ActiveRecord::Migration
  def up
    add_column :users, :password_set, :boolean, default: true

    user_arel_table = User.arel_table
    # Set `password_set` to false for...
    User.where(user_arel_table[:active].eq(false) # Users who have an account through the reserve username flow
      .or(user_arel_table[:provider].not_eq(nil)  # active Users who have an account through connecting with Facebook or Twitter
        .and(user_arel_table[:active].eq(true))
      )
    ).update_all password_set: false
  end

  def down
    remove_column :users, :password_set
  end
end
