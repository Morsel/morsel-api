ActiveAdmin.register User do
  actions :index, :show, :edit

  filter :id
  filter :email
  filter :username
  filter :first_name
  filter :last_name
  filter :sign_in_count
  filter :promoted, label: 'Suggested'
  filter :professional

  scope_to do
    Class.new do
      def self.users
        User.unscoped
      end
    end
  end

  scope :all, default: true
  scope :active
  scope :inactive
  scope :suggested
  scope :professional

  member_action :history do
    @versions = resource.versions
    render 'layouts/history'
  end

  member_action :shadow do
    user = User.find(params[:id])
    shadow_token_service = GenerateShadowToken.call(user: user)
    if shadow_token_service.valid?
      redirect_to("#{Settings.morsel.web_url}/admin/shadow?user_id=#{user.id}&shadow_token=#{shadow_token_service.response}", target: :_blank)
    end
  end

  controller do
    def update
      user = User.find params[:id]
      if user.update(UsersController::UserParams.build(params, current_user))
        redirect_to(edit_admin_user_path(user), notice: 'User updated!')
      else
        redirect_to(edit_admin_user_path(user), alert: 'Error updating user, ask Marty for help.')
      end
    end
  end

  index do
    column 'Status' do |user|
      if user.deleted?
        status_tag('Deleted', :error)
      elsif user.active?
        status_tag('Active', :ok)
      else
        status_tag('Inactive', :warning)
      end
    end
    column :id do |user|
      link_to user.id, admin_user_path(user)
    end
    column 'Links' do |user|
      links = ''.html_safe
      links += link_to 'Edit', edit_admin_user_path(user.id)
      unless user.deleted?
        links += '<br />'.html_safe
        links += link_to('View on Web', user.url, target: :_blank)
        links += '<br />'.html_safe
        links += link_to('Shadow', shadow_admin_user_path(user), target: :_blank)
      end
      links
    end
    column :email
    column :username
    column :first_name
    column :last_name
    column :photo do |user|
      link_to(image_tag(user.photo.url(:_80x80)), user.photo_url, target: :_blank) if user.photo_url
    end
    column :bio
    column :promoted, label: 'Suggested'
    column :professional
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :created_at
    column :updated_at
    column :deleted_at
  end

  show do |user|
    attributes_table do
      row 'Status' do
        if user.deleted?
          status_tag('Deleted', :error)
        elsif user.active?
          status_tag('Active', :ok)
        else
          status_tag('Inactive', :warning)
        end
      end
      row :id
      row 'Links' do
        links = ''.html_safe
        unless user.deleted?
          links += link_to('View on Web', user.url, target: :_blank) if user.url
        end
        links
      end
      row :email
      row :username
      row :first_name
      row :last_name
      row :photo do
        link_to(image_tag(user.photo.url(:_80x80)), user.photo_url, target: :_blank) if user.photo_url
      end
      row :bio
      row :promoted, label: 'Suggested'
      row :professional
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
      row :deleted_at
    end

    panel 'Places' do
      table_for user.places.order(Place.arel_table[:name].asc) do
        column :id
        # column :id do |place|
        #   link_to place.id, admin_place_path(place)
        # end
        column 'Links' do |place|
          links = ''.html_safe
          unless place.deleted?
            links += link_to('View on Web', place.url, target: :_blank)
            links += '<br />'.html_safe
          end
          links += link_to('View Widget', place.widget_url, target: :_blank) if place.widget_url
          # links += link_to 'Edit', edit_admin_place_path(place.id)
          links
        end
        column :name
        column :slug
        column :address
        column :city
        column :state
        column :postal_code
        column :country
        column :Facebook do |place|
          link_to(place.facebook_page_id, place.facebook_url, target: :_blank) if place.facebook_page_id
        end
        column :Twitter do |place|
          link_to(place.twitter_username, place.twitter_url, target: :_blank) if place.twitter_username
        end
        column :Foursquare do |place|
          link_to(place.foursquare_venue_id, place.foursquare_url, target: :_blank) if place.foursquare_venue_id
        end
        column :creator
        column :created_at
        column :updated_at
        column :deleted_at
        column :last_imported_at
      end
    end

    panel 'Morsels' do
      table_for user.morsels do
        column 'Status' do |morsel|
          if morsel.deleted?
            status_tag('Deleted', :error)
          elsif morsel.draft?
            status_tag('Draft', :warning)
          else
            status_tag('Published', :ok)
          end
        end
        column :id do |morsel|
          link_to morsel.id, admin_morsel_path(morsel)
        end
        column 'Links' do |morsel|
          links = ''.html_safe
          links += link_to 'Edit', edit_admin_morsel_path(morsel.id)
          unless morsel.deleted?
            links += '<br />'.html_safe
            links += link_to('View on Web', morsel.url, target: :_blank)
          end
          links
        end
        column :title
        column :draft
        column :creator
        column 'Collage' do |morsel|
          link_to(image_tag(morsel.photo_url, size: '280x140'), morsel.photo_url, target: :_blank) if morsel.photo_url
        end
        column 'Cover Item' do |morsel|
          link_to("#{morsel.primary_item_id}", admin_item_path(morsel.primary_item)) if morsel.primary_item
        end
        column :place
        column :featured do |morsel|
          status_tag('Featured', :ok) if morsel.feed_item && morsel.feed_item.featured
        end
        column :created_at
        column :published_at
        column :updated_at
        column :deleted_at
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'User' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :bio
      f.input :promoted, as: :boolean, label: 'Find People Suggested'
      f.input :professional, as: :boolean
    end

    f.actions
  end
end
