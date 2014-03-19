class UpdateMorsel < ActiveInteraction::Base
  model :morsel, :user

  hash :params do
    string  :description, default: nil
    string  :nonce,       default: nil
    integer :sort_order,  default: nil
    integer :post_id,     default: nil

    hash    :post,        default: nil do
      integer :id,    default: nil
      string  :title, default: nil
    end
  end

  hash :uploaded_photo_hash, default: nil do
    string :type,            default: nil
    string :head,            default: nil
    string :filename,        default: nil
    file   :tempfile,        default: nil
  end

  boolean :post_to_facebook, default: false
  boolean :post_to_twitter,  default: false

  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to update Morsel') unless user.can_update?(morsel) }

  def execute
    post_params = params.extract!(:post)[:post]
    if post_params && post_params[:id].present?
      post = Post.find(post_params[:id])

      # Specified Post w/ post_id does not exist. Possibly deleted or just never existed.
      raise ActiveRecord::RecordNotFound if post_params[:id] && post.nil?

      # Post has changed
      if post && post != morsel.post
        morsel.post = post
      else
        post = morsel.post
      end

      post.title = post_params[:title] if post_params[:title].present?
    end

    morsel.photo = ActionDispatch::Http::UploadedFile.new(uploaded_photo_hash) if uploaded_photo_hash

    morsel.description = params[:description] if params[:description].present?
    morsel.nonce = params[:nonce] if params[:nonce].present?
    morsel.sort_order = params[:sort_order] if params[:sort_order].present?
    morsel.post_id = params[:post_id] if params[:post_id].present?
    morsel.photo

    morsel.post = post if post

    if morsel.save
      morsel.errors.add(:post, post.errors) unless post.save if post
      user.post_to_facebook(morsel.facebook_message) if post_to_facebook
      user.post_to_twitter(morsel.twitter_message) if post_to_twitter
    end

    errors.merge!(morsel.errors)
    morsel
  end
end
