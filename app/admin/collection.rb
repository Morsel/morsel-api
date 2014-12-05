ActiveAdmin.register Collection do
  menu false

  config.clear_sidebar_sections!

  member_action :history do
    @versions = resource.versions
    render 'layouts/history'
  end
end
