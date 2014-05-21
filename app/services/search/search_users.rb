module Search
  class SearchUsers
    include Service
    include Virtus.model

    attribute :query, String
    attribute :first_name, String
    attribute :last_name, String
    attribute :promoted, Boolean

    def call
      if query.present?
        SearchableUser.where('first_name ILIKE :query OR last_name ILIKE :query', query: query)
                      .promoted(promoted)
      else
        SearchableUser.first_name(first_name)
                      .last_name(last_name)
                      .promoted(promoted)
      end
    end

  end

  class SearchableUser < User
    scope :first_name, -> (first_name) { where("first_name ILIKE ?", first_name) if first_name.present? }
    scope :last_name, -> (last_name) { where("last_name ILIKE ?", last_name) if last_name.present? }
    scope :promoted, -> (promoted) { where("promoted = ?", promoted) if promoted.present? }
  end
end
