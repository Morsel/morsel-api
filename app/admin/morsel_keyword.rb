ActiveAdmin.register MorselKeyword do
  actions :index,:new,:edit,:update,:create
  permit_params :name

  before_create do |morselkeyword|
  	
    morselkeyword.user_id = current_user.id
  
  end
end
