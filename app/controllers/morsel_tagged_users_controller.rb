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

  PUBLIC_ACTIONS << def users
    custom_respond_with User.joins(:morsel_tagged_users)
                            .paginate(pagination_params)
                            .where(morsel_tagged_users: { morsel_id: params[:id] })
                            .order(MorselTaggedUser.arel_table[:id].desc)
  end

  def destroy
    morsel_tagged_user = MorselTaggedUser.find_by(morsel_id: params[:id], user_id: params[:user_id])

    return record_not_found unless morsel_tagged_user

    authorize_action_for morsel_tagged_user

    if morsel_tagged_user.destroy
      render_json_ok
    else
      render_json_errors morsel_tagged_user.errors
    end
  end

  private

  authorize_actions_for MorselTaggedUser, except: PUBLIC_ACTIONS
end
