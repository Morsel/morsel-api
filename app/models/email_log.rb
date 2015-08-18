class EmailLog < ActiveRecord::Base
	belongs_to :morsel
	belongs_to :user
end
