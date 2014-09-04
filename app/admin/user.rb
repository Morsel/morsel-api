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

  controller do
    def update
      user = User.find params[:id]
      if user.update(UsersController::UserParams.build(params, current_user))
        redirect_to(edit_admin_user_path(user), { notice: 'User updated!' })
      else
        redirect_to(edit_admin_user_path(user), { alert: 'Error updating user, ask Marty for help.' })
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
    column :id
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
    actions defaults: true do |user|
      link_to ' View on Web', user.url
    end
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
      row 'Links' do
        links = ''.html_safe
        if user.url
          links += link_to(' View on Web', user.url, target: :_blank)
        end
        links
      end
    end

    panel 'Places' do
      table_for user.places.order(Place.arel_table[:name].asc) do
        column :id
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
        column '' do |place|
          links = ''.html_safe
          links += link_to(' View on Web', place.url, target: :_blank)
          links += link_to(' Widget', place.widget_url, target: :_blank) if place.widget_url
          # links += link_to ' Edit', edit_admin_place_path(place.id)
          links
        end
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
        column :id
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
          morsel.feed_item.featured if morsel.feed_item
        end
        column :created_at
        column :published_at
        column :updated_at
        column :deleted_at
        column '' do |morsel|
          links = ''.html_safe
          links += link_to(' View on Web', morsel.url, target: :_blank)
          links += link_to ' Edit', edit_admin_morsel_path(morsel.id)
          links
        end
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
