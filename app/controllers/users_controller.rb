class UsersController < ApiController
  respond_to :json

  def index
    @users = User.all
  end

  def show
    @user = User.find_by_id_or_username(params[:user_id_or_username])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(UserParams.build(params))
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                   :first_name, :last_name, :photo, :title, :bio)
    end
  end
end
