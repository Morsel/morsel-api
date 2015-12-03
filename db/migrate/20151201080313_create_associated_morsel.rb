class CreateAssociatedMorsel < ActiveRecord::Migration
  def change
    create_table :associated_morsels do |t|
      t.integer :morsel_id
      t.integer :host_id

      t.timestamps
    end
  end
end
