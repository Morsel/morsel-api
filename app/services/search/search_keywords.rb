module Search
  class SearchKeywords
    include Service

    attribute :query, String
    attribute :type, String
    attribute :promoted, Boolean
    attribute :count, Integer
    attribute :max_id, Integer
    attribute :since_id, Integer

    validates :query,
              allow_blank: true,
              length: { minimum: 3 }

    def call
      if query.present?
        Keyword.paginate({
          since_id: since_id,
          max_id: max_id,
          count: count
        }, :id, Keyword)
        .search_query(query)
        .search_promoted(promoted)
        .where(type: type)
        .order(Keyword.arel_table[:id].desc)
      else
        Keyword.paginate({
          since_id: since_id,
          max_id: max_id,
          count: count
        }, :id, Keyword)
        .search_promoted(promoted)
        .where(type: type)
        .order(Keyword.arel_table[:id].desc)
      end
    end
  end

  class ::Keyword
    concerning :Search do
      included do
        scope :search_query, -> (search_query) {
          where(
            Keyword.arel_table[:name].matches("%#{search_query}%")
          ) if search_query.present?
        }
        scope :search_promoted, -> (search_promoted) { where('promoted = ?', search_promoted) if search_promoted.present? }
      end
    end
  end
end
