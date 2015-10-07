class AssociationRequest < ActiveRecord::Base
	belongs_to :host , :class_name => "User"
	belongs_to :associated_user , :class_name => "User"

	scope :approved, -> { where(approved: true) }

	def approve!
		self.update_attribute(:approved , true)
	end

end
