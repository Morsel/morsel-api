class CreateMorsel < ActiveInteraction::Base
  model   :user

  hash :params do
    string :description, default: nil
    string :nonce, default: nil
  end

  hash :uploaded_photo_hash, default: nil do
    string :type, default: nil
    string :head, default: nil
    string :filename, default: nil
    file :tempfile, default: nil
  end

  integer :post_id, default: nil
  string  :post_title, default: nil
  integer :sort_order, default: nil
  boolean :post_to_facebook, default: false
  boolean :post_to_twitter, default: false

  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to create Morsel') unless user.can_create?(Morsel) }

  def execute
    photo = ActionDispatch::Http::UploadedFile.new(uploaded_photo_hash) if uploaded_photo_hash
    morsel = user.morsels.build(
      description: params[:description],
      nonce: params[:nonce],
      photo: photo
    )

    if morsel.save
      post = Post.find_or_initialize_by(id: post_id) do |p|
        p.id = nil
        p.creator = user
      end

      post.title = post_title if post_title

      MorselPost.create(morsel: morsel, post: post, sort_order: sort_order.presence)

      if post.save
        user.post_to_facebook(morsel.facebook_message(post)) if post_to_facebook
        user.post_to_twitter(morsel.twitter_message(post)) if post_to_twitter
      else
        morsel.errors.add(:post, post.errors)
      end
    end

    errors.merge!(morsel.errors)

    {
      morsel: morsel,
      post: post
    }
  end
end

# active_interaction only allows uploading File or Tempfile, so the UploadedFile used by CarrierWave is converted to a Hash then recreated
class CreateMorselUploadedPhotoHash
  def self.hash(params)
    if params
      {
        type: params.content_type,
        head: params.headers,
        filename: params.original_filename,
        tempfile: params.tempfile
      }
    end
  end
end
