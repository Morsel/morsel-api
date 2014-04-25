class KeywordsController < ApiController
  PUBLIC_ACTIONS = [:cuisines, :specialties, :users]
  authorize_actions_for Keyword, except: PUBLIC_ACTIONS, actions: { users: :read }

  def cuisines
    custom_respond_with Keyword.where(type: 'Cuisine'), each_serializer: KeywordSerializer
  end

  def specialties
    custom_respond_with Keyword.where(type: 'Specialty'), each_serializer: KeywordSerializer
  end

  # get 'keywords/:id/users' => 'keywords#users'
  def users
    # TODO: Paginate
    custom_respond_with User.joins("LEFT OUTER JOIN tags ON tags.taggable_type = 'User' AND tags.taggable_id = users.id")
                          .where('tags.keyword_id = ?', params[:id])
                          .order('users.id DESC')
  end
end
