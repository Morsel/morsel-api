module Search
  class SearchUsers
    include Service

    attribute :query, String
    attribute :first_name, String
    attribute :last_name, String
    attribute :username, String
    attribute :promoted, Boolean
    attribute :count, Integer
    attribute :max_id, Integer
    attribute :since_id, Integer

    validates :query,
              allow_blank: true,
              length: { minimum: 3 }

    def call
      if query.present?
        formatted_query = "#{query}%"
        SearchableUser.paginate({
                        since_id: since_id,
                        max_id: max_id,
                        count: count
                      }, :id, SearchableUser)
                      .where(
                        SearchableUser.arel_table[:first_name].matches(formatted_query)
                        .or(SearchableUser.arel_table[:last_name].matches(formatted_query))
                        .or(SearchableUser.arel_table[:username].matches(formatted_query))
                      )
                      .search_promoted(promoted)
                      .order(SearchableUser.arel_table[:id].desc)
      else
        SearchableUser.paginate({
                        since_id: since_id,
                        max_id: max_id,
                        count: count
                      }, :id, SearchableUser)
                      .search_first_name(first_name)
                      .search_last_name(last_name)
                      .search_username(username)
                      .search_promoted(promoted)
                      .order(SearchableUser.arel_table[:id].desc)
      end
    end
  end

  class SearchableUser < User
    scope :search_first_name, -> (search_first_name) { where(SearchableUser.arel_table[:first_name].matches("#{search_first_name}%")) if search_first_name.present? }
    scope :search_last_name, -> (search_last_name) { where(SearchableUser.arel_table[:last_name].matches("#{search_last_name}%")) if search_last_name.present? }
    scope :search_username, -> (search_username) { where(SearchableUser.arel_table[:username].matches("#{search_username}%")) if search_username.present? }
    scope :search_promoted, -> (search_promoted) { where('promoted = ?', search_promoted) if search_promoted.present? }
  end
end
