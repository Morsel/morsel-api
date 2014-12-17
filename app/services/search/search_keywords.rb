module Search
  class SearchKeywords
    include Service

    attribute :query, String
    attribute :type, String
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
        Keyword.paginate({
          since_id: since_id,
          max_id: max_id,
          page: page,
          count: count
        }, :id, Keyword)
        .where(type: type)
        .search_query(safe_query)
        .search_promoted(promoted)
        .order(Keyword.arel_table[:id].desc)
      else
        Keyword.paginate({
          since_id: since_id,
          max_id: max_id,
          page: page,
          count: count
        }, :id, Keyword)
        .where(type: type)
        .search_promoted(promoted)
        .order(Keyword.arel_table[:id].desc)
      end
    end

    private

    def hashtag?
      type == 'Hashtag'
    end

    def safe_query
      if hashtag? && query.starts_with?('#')
        query[1..-1]
      else
        query
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
