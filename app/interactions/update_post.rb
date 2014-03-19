class UpdatePost < ActiveInteraction::Base
  model :post, :user

  hash :params do
    string  :title, default: nil
    boolean :draft, default: nil
  end

  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to update Post') unless user.can_update?(post) }

  def execute
    post.title = params[:title] unless params[:title].nil?
    post.draft = params[:draft] unless params[:draft].nil?
    post.save

    errors.merge!(post.errors)
    post
  end
end
