ActiveAdmin.register Morsel do
  actions :index, :show, :edit

  before_filter do
    Morsel.class_eval do
      def to_param
        id.to_s
      end
    end
  end

  filter :id
  filter :title

  scope_to do
    Class.new do
      def self.morsels
        Morsel.unscoped
      end
    end
  end

  scope :all, default: true
  scope :drafts
  scope :published

  controller do
    def update
      morsel = Morsel.find params[:id]
      if morsel.update(MorselsController::MorselParams.build(params, current_user))
        redirect_to(edit_admin_morsel_path(morsel), { notice: 'Morsel updated!' })
      else
        redirect_to(edit_admin_morsel_path(morsel), { alert: 'Error updating morsel, ask Marty for help.' })
      end
    end
  end

  index do
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
    actions defaults: true do |morsel|
      link_to('View on Web', morsel.url, target: :_blank)
    end
  end

  show do |morsel|
    attributes_table do
      row 'Status' do
        if morsel.deleted?
          status_tag('Deleted', :error)
        elsif morsel.draft?
          status_tag('Draft', :warning)
        else
          status_tag('Published', :ok)
        end
      end
      row :id
      row :title
      row :draft
      row :creator
      row 'Collage' do
        link_to(image_tag(morsel.photo_url), morsel.photo_url, target: :_blank) if morsel.photo_url
      end
      row 'Cover Item' do
        link_to("#{morsel.primary_item_id}", admin_item_path(morsel.primary_item)) if morsel.primary_item_id
      end
      row :place
      row :featured do
        morsel.feed_item.featured if morsel.feed_item
      end
      row :created_at
      row :published_at
      row :updated_at
      row :deleted_at
      row 'Links' do
        links = ''.html_safe
        if morsel.url
          links += link_to('View on Web', morsel.url, target: :_blank)
        end
        links
      end
    end

    panel 'Items' do
      table_for morsel.items do
        column :sort_order
        column :id
        column :description
        column :photo do |item|
          link_to(image_tag(item.photo_url(:_80x80)), item.photo_url, target: :_blank) if item.photo_url
        end
        column :creator
        column :morsel do |item|
          item.morsel.title
        end
        column :created_at
        column :updated_at
        column :deleted_at
        column '' do |item|
          links = ''.html_safe
          links += link_to 'Edit', edit_admin_item_path(item.id)
          links
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'Morsel' do
      f.input :title
    end

    f.inputs 'Feed Item', for: [:feed_item, f.object.feed_item] do |fi_f|
      fi_f.input :featured, as: :boolean, input_html: { disabled: f.object.draft }
    end
    f.actions
  end
end