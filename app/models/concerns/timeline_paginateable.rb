module TimelinePaginateable
  extend ActiveSupport::Concern

  included do
    scope :since, -> (since_id, table_name = self.table_name) { where("#{table_name}.id > ?", since_id) if since_id.present? }
    scope :max, -> (max_id, table_name = self.table_name) { where("#{table_name}.id <= ?", max_id) if max_id.present? }
  end
end
