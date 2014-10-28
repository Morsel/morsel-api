# ## Schema Information
#
# Table name: `collection_morsels`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`collection_id`**  | `integer`          |
# **`morsel_id`**      | `integer`          |
# **`sort_order`**     | `integer`          |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
# **`note`**           | `text`             |
#

class CollectionMorsel < ActiveRecord::Base
  include Authority::Abilities

  acts_as_paranoid

  before_save :check_sort_order

  belongs_to :collection
  belongs_to :morsel

  validates :collection,
    presence: true,
    uniqueness: { scope: [:morsel_id], conditions: -> { where(deleted_at: nil) } }

  validates :morsel,
    presence: true,
    uniqueness: { scope: [:collection_id], conditions: -> { where(deleted_at: nil) } }


  private

  def check_sort_order
    if sort_order_changed?
      existing_collection_morsel = CollectionMorsel.find_by(collection:collection, morsel: morsel, sort_order: sort_order)

      # If the sort_order has been taken, increment the sort_order for every collection_morsel >= sort_order
      collection.collection_morsels.where('collection_id = ? AND sort_order >= ?', collection.id, sort_order).update_all('sort_order = sort_order + 1') if existing_collection_morsel
    end

    self.sort_order = generate_sort_order if sort_order.blank?
  end

  def generate_sort_order
    last_sort_order = collection.collection_morsels.maximum(:sort_order)
    if last_sort_order.present?
      last_sort_order + 1
    else
      1
    end
  end
end
