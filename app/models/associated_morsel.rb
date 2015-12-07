class AssociatedMorsel < ActiveRecord::Base
  belongs_to :morsel
  belongs_to :hostuser, class_name: "User", :foreign_key => 'host_id'
end
