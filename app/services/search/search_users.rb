module Search
  class SearchUsers
    include Service

    attribute :query, String
    attribute :first_name, String
    attribute :last_name, String
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
                      }, SearchableUser)
                      .where(
                        SearchableUser.arel_table[:first_name].matches(formatted_query)
                        .or(SearchableUser.arel_table[:last_name].matches(formatted_query))
                      )
                      .promoted(promoted)
                      .order(SearchableUser.arel_table[:id].desc)
      else
        SearchableUser.paginate({
                        since_id: since_id,
                        max_id: max_id,
                        count: count
                      }, SearchableUser)
                      .first_name(first_name)
                      .last_name(last_name)
                      .promoted(promoted)
                      .order(SearchableUser.arel_table[:id].desc)
      end
    end
  end

  class SearchableUser < User
    scope :first_name, -> (first_name) { where(SearchableUser.arel_table[:first_name].matches("#{first_name}%")) if first_name.present? }
    scope :last_name, -> (last_name) { where(SearchableUser.arel_table[:last_name].matches("#{last_name}%")) if last_name.present? }
    scope :promoted, -> (promoted) { where('promoted = ?', promoted) if promoted.present? }
  end
end
