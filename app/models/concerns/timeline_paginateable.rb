module TimelinePaginateable
  extend ActiveSupport::Concern

  included do
    scope :since, -> (since_id, klass = self) { where(klass.arel_table[:id].gt(since_id)) if since_id.present? }
    scope :max, -> (max_id, klass = self) { where(klass.arel_table[:id].lteq(max_id)) if max_id.present? }
    scope :paginate, -> (pagination_params, klass = self) { since(pagination_params[:since_id], klass).max(pagination_params[:max_id], klass).limit(pagination_params[:count]) }
  end
end
