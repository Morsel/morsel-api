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
    attribute :page, Integer

    validates :query,
              allow_blank: true,
              length: { minimum: 3 }

    def call
      if query.present?
        SearchableUser.paginate({
          since_id: since_id,
          max_id: max_id,
          page: page,
          count: count
        }, :id, SearchableUser)
        .search_query(query)
        .search_promoted(promoted)
        .where(active: true)
        .order(SearchableUser.arel_table[:id].desc)
      else
        SearchableUser.paginate({
          since_id: since_id,
          max_id: max_id,
          page: page,
          count: count
        }, :id, SearchableUser)
        .search_first_name(first_name)
        .search_last_name(last_name)
        .search_username(username)
        .search_promoted(promoted)
        .where(active: true)
        .order(SearchableUser.arel_table[:id].desc)
      end
    end
  end
end
