class EmailLog < ActiveRecord::Base
	belongs_to :morsel
	belongs_to :user

	def self.email_per_day
		where("created_at::date = ?",Date.today).count
    end
end
