class MorselUserTagsController < ApiController
  def create
    morsel_user_tag = MorselUserTag.new(morsel_id: params[:id], user_id: params[:user_id])
    authorize_action_for morsel_user_tag

    if morsel_user_tag.save
      custom_respond_with morsel_user_tag
    else
      render_json_errors morsel_user_tag.errors
    end
  end

  PUBLIC_ACTIONS << def users
    custom_respond_with User.joins(:morsel_user_tags)
                            .paginate(pagination_params)
                            .where(morsel_user_tags: { morsel_id: params[:id] })
                            .order(MorselUserTag.arel_table[:id].desc),
                        each_serializer: SlimUserSerializer
  end

  PUBLIC_ACTIONS << def eligible_users
    # Eligible Users currently are those that follow the User
    morsel = Morsel.find params[:id]

    query = params[:query]
    query += '%' if query

    custom_respond_with Search::SearchableUser.joins(:followable_follows)
                            .paginate(pagination_params)
                            .search_query(query)
                            .where(follows: { followable_id: morsel.creator_id, followable_type: User })
                            .where(active: true),
                        each_serializer: SlimTaggedUserSerializer,
                        context: {
                          morsel: morsel
                        }
  end

  def destroy
    morsel_user_tag = MorselUserTag.find_by(morsel_id: params[:id], user_id: params[:user_id])

    return record_not_found unless morsel_user_tag

    authorize_action_for morsel_user_tag

    if morsel_user_tag.destroy
      render_json_ok
    else
      render_json_errors morsel_user_tag.errors
    end
  end

  private

  authorize_actions_for MorselUserTag, except: PUBLIC_ACTIONS
end
