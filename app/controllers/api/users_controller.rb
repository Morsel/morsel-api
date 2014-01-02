class Api::UsersController < Api::ApiController
  respond_to :json

  def create
    user = User.create(UserParams.build(params))

    render json: { user: user.as_json(auth_token: user.authentication_token) }, status: :created
    respond_with user, location: root_path
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(UserParams.build(params))

    respond_with user, location: root_path
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :password, :password_confirmation,
                                   :first_name, :last_name, :profile)
    end
  end
end
