ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Recent Items' do
          ul do
            Item.includes(:creator, :morsel).limit(5).order('created_at DESC').map do |item|
              li link_to(item.description, admin_item_path(item))
            end
          end
        end
      end
    end
  end
end
