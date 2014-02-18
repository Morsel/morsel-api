module TimelinePaginateable
  extend ActiveSupport::Concern

  included do
    scope :since, -> (since_id) { where('id > ?', since_id) if since_id.present? }
    scope :max, -> (max_id) { where('id <= ?', max_id) if max_id.present? }
  end
end
