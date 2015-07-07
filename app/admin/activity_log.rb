ActiveAdmin.register ActivityLog do

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

   index do
    column "IP Address", :ip_address
    column "Origin", :host_site
    column "Share Type", :share_by
    column "Activity", :activity
    column "User Id", :user_id
    column "Object Id", :activity_id
    column "Object Type", :activity_type

     # actions
  end

  
end
