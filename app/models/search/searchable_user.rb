module Search
  class SearchableUser < User
    scope :search_first_name, -> (search_first_name) { where(SearchableUser.arel_table[:first_name].matches("#{search_first_name}%")) if search_first_name.present? }
    scope :search_last_name, -> (search_last_name) { where(SearchableUser.arel_table[:last_name].matches("#{search_last_name}%")) if search_last_name.present? }
    scope :search_username, -> (search_username) { where(SearchableUser.arel_table[:username].matches("#{search_username}%")) if search_username.present? }
    scope :search_query, -> (search_query) { where(
      SearchableUser.arel_table[:first_name].matches(search_query)
      .or(SearchableUser.arel_table[:last_name].matches(search_query))
      .or(SearchableUser.arel_table[:username].matches(search_query))
      ) if search_query.present?
    }
    scope :search_promoted, -> (search_promoted) { where('promoted = ?', search_promoted) if search_promoted.present? }
  end
end
