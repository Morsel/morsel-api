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
        SearchableUser.since(since_id)
                      .max(max_id)
                      .where('first_name ILIKE :query OR last_name ILIKE :query', query: query)
                      .promoted(promoted)
                      .limit(count)
                      .order('id DESC')
      else
        SearchableUser.since(since_id)
                      .max(max_id)
                      .first_name(first_name)
                      .last_name(last_name)
                      .promoted(promoted)
                      .limit(count)
                      .order('id DESC')
      end
    end
  end

  class SearchableUser < User
    scope :first_name, -> (first_name) { where('first_name ILIKE ?', first_name) if first_name.present? }
    scope :last_name, -> (last_name) { where('last_name ILIKE ?', last_name) if last_name.present? }
    scope :promoted, -> (promoted) { where('promoted = ?', promoted) if promoted.present? }
  end
end
