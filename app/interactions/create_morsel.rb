class CreateMorsel < ActiveInteraction::Base
  model   :user

  hash :params do
    string :description, default: nil
    string :nonce, default: nil
    integer :sort_order, default: nil
    integer :post_id, default: nil
    hash :post, default: nil do
      integer :id, default: nil
      string :title, default: nil
    end
  end

  hash :uploaded_photo_hash, default: nil do
    string :type, default: nil
    string :head, default: nil
    string :filename, default: nil
    file :tempfile, default: nil
  end

  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to create Morsel') unless user.can_create?(Morsel) }

  def execute
    post_params = params.extract!(:post)[:post]
    post = Post.find(post_params[:id])

    # Specified Post w/ post_id does not exist. Possibly deleted or just never existed.
    raise ActiveRecord::RecordNotFound if post_params[:id].present? && post.nil?

    post.title = post_params[:title] if post_params[:title].present?

    morsel = user.morsels.build(
      description: params[:description],
      nonce: params[:nonce],
      sort_order: params[:sort_order]
    )

    morsel.photo = ActionDispatch::Http::UploadedFile.new(uploaded_photo_hash) if uploaded_photo_hash
    morsel.post = post

    if morsel.save
      morsel.errors.add(:post, post.errors) unless post.save
    end

    errors.merge!(morsel.errors)
    morsel
  end
end
