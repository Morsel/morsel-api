class UsersController < ApiController
  skip_before_filter :authenticate_user_from_token!, only: [:show, :checkusername, :reserveusername, :setrole, :unsubscribe]

  def index
    custom_respond_with User.all
  end

  def me
    custom_respond_with current_user, serializer: UserWithPrivateAttributesSerializer
  end

  def checkusername
    check_username_exists = CheckUsernameExists.run(
      username: params[:username]
    )

    if check_username_exists.valid?
      render_json "#{check_username_exists.result}"
    else
      render_json_errors check_username_exists.errors
    end
  end

  def reserveusername
    reserve_username = ReserveUsername.run(
      username: params[:username],
      email: params[:email]
    )

    if reserve_username.valid?
      user = reserve_username.result
      create_user_event(:reserved_username, user.id)
      EmailUserDecorator.new(user).send_reserved_username_email
      sign_in user, store: false
      render_json(user_id: "#{user.id}")
    else
      render_json_errors reserve_username.errors
    end
  end

  def updateindustry
    update_user_industry = UpdateUserIndustry.run(
      user_id: params[:id],
      industry: params[:industry]
    )

    if update_user_industry.valid?
      render_json 'OK'
    else
      render_json_errors update_user_industry.errors
    end
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
      render_json_errors(user.errors)
    end
  end

  def unsubscribe
    unsubscribe_user = UnsubscribeUser.run(
      email: params[:email]
    )

    if unsubscribe_user.valid?
      render_json 'OK'
    else
      render_json_errors unsubscribe_user.errors
    end
  end

  class UserParams
    def self.build(params)
      params.require(:user).permit(:email, :username, :password, :password_confirmation,
                                   :first_name, :last_name, :photo, :title, :bio, :industry)
    end
  end
end
