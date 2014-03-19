class RegisterUser < ActiveInteraction::Base
  hash :params do
    string :email
    string :username
    string :password
    string :first_name, default: nil
    string :last_name,  default: nil
    string :title,      default: nil
    string :bio,        default: nil
    string :industry,   default: nil
  end

  hash :uploaded_photo_hash, default: nil do
    string :type, default: nil
    string :head, default: nil
    string :filename, default: nil
    file :tempfile, default: nil
  end

  def execute
    user = User.new(params)
    user.photo = ActionDispatch::Http::UploadedFile.new(uploaded_photo_hash) if uploaded_photo_hash

    user.save
    errors.merge!(user.errors)

    user
  end
end
