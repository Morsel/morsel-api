class UsersController < ApiController
  respond_to :json

  def index
    custom_respond_with User.all
  end

  def show
    user = User.includes(:authorizations, :posts, :morsels).find_by_id_or_username(params[:user_id_or_username])
    raise ActiveRecord::RecordNotFound if user.nil?

    custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(UserParams.build(params))
      custom_respond_with user, serializer: UserWithPrivateAttributesSerializer
    else
      render_json_errors(user.errors, :unprocessable_entity)
    end
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                   :first_name, :last_name, :photo, :title, :bio)
    end
  end
end
