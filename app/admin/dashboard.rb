ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Recent Morsels' do
          ul do
            Morsel.feed.limit(5).order('created_at DESC').map do |morsel|
              li link_to(morsel.description, admin_morsel_path(morsel))
            end
          end
        end
      end
    end
  end
end
