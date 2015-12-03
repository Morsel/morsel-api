class AssociatedMorsel < ActiveRecord::Base
  belongs_to :morsel
  belongs_to :user, :foreign_key => 'host_id'
end
