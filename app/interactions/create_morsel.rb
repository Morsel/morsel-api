class CreateMorsel < ActiveInteraction::Base
  model   :user

  string  :description, default: nil

  hash :uploaded_photo_hash, default: nil do
    string :type, default: nil
    string :head, default: nil
    string :filename, default: nil
    file :tempfile, default: nil
  end

  boolean :draft, default: false

  integer :post_id, default: nil
  string :post_title, default: nil
  integer :sort_order, default: nil

  boolean :post_to_facebook, default: false
  boolean :post_to_twitter, default: false

  validates :user, presence: true

  def execute
    photo = ActionDispatch::Http::UploadedFile.new(uploaded_photo_hash) if uploaded_photo_hash
    morsel = user.morsels.build(
      description: description,
      photo: photo,
      draft: draft
    )

    if morsel.save
      post = Post.find_or_initialize_by(id: post_id) do |p|
        p.id = nil
        p.creator = user
      end

      post.title = post_title if post_title

      post.morsels.push morsel
      post.set_sort_order_for_morsel(morsel.id, sort_order) if sort_order

      if post.save
        user.post_to_facebook(morsel.facebook_message(post)) if post_to_facebook
        user.post_to_twitter(morsel.twitter_message(post)) if post_to_twitter
      else
        morsel.errors.add(:post, post.errors)
      end
    end

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
