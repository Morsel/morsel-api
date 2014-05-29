class KeywordsController < ApiController
  PUBLIC_ACTIONS << def cuisines
    custom_respond_with Keyword.where(type: 'Cuisine'), each_serializer: KeywordSerializer
  end

  PUBLIC_ACTIONS << def specialties
    custom_respond_with Keyword.where(type: 'Specialty'), each_serializer: KeywordSerializer
  end

  PUBLIC_ACTIONS << def users
    custom_respond_with User.joins(:tags)
                            .since(params[:since_id], 'users')
                            .max(params[:max_id], 'users')
                            .where(tags: { keyword_id: params[:id] })
                            .limit(pagination_count)
                            .order('tags.id DESC')
  end

  private

  authorize_actions_for Keyword, except: PUBLIC_ACTIONS, actions: { users: :read }
end
