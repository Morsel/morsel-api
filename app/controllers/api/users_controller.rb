class Api::UsersController < Api::ApiController
  respond_to :html, :json

  def create
    user = User.create(UserParams.build(params))

    respond_with user, location: root_path
  end

  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def update
    user_params = UserParams.build(params)
    user = User.find(user_params[:id])
    user.update_attributes(user_params)

    respond_with user, location: root_path
  end

  def me
    @user = current_user
    respond_with @user
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
  end
end
