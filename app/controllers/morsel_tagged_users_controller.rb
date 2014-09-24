class MorselTaggedUsersController < ApiController
  def create
    morsel_tagged_user = MorselTaggedUser.new(morsel_id: params[:id], user_id: params[:user_id])
    authorize_action_for morsel_tagged_user

    if morsel_tagged_user.save
      custom_respond_with morsel_tagged_user
    else
      render_json_errors morsel_tagged_user.errors
    end
  end

  private

  authorize_actions_for MorselTaggedUser, except: PUBLIC_ACTIONS
end
