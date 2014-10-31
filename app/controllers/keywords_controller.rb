class KeywordsController < ApiController
  public_actions << def cuisines
    custom_respond_with Keyword.where(type: 'Cuisine'), each_serializer: KeywordSerializer
  end

  public_actions << def specialties
    custom_respond_with Keyword.where(type: 'Specialty'), each_serializer: KeywordSerializer
  end

  public_actions << def users
    custom_respond_with User.joins(:tags)
                            .paginate(pagination_params)
                            .where(tags: { keyword_id: params[:id] })
                            .order(Tag.arel_table[:id].desc)
  end

  private

  authorize_actions_for Keyword, except: public_actions, actions: { users: :read }
end
