require 'rake'
namespace :update_auth_emails do
  desc 'update authencation user emails'
  task auth_emails: :environment do
    Authentication.where(:provider=>"facebook").each do |auth|
      user = User.find_by_id(auth.user_id)
      auth.email=user.email
      auth.save!
    end
  end
end
