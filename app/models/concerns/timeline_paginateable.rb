module TimelinePaginateable
  extend ActiveSupport::Concern

  included do
    scope :since, -> (since_id, klass = self) do
      where(klass.arel_table[:id].gt(since_id)) if since_id.present?
    end

    scope :after_date, -> (after_date, date_key, after_id = nil, klass = self) do
      where("(#{klass.table_name}.#{date_key}, #{klass.table_name}.id) > (?, ?)", after_date, after_id) if after_date.present?
    end

    scope :max, -> (max_id, klass = self) do
      where(klass.arel_table[:id].lteq(max_id)) if max_id.present?
    end

    scope :before_date, -> (before_date, date_key, before_id = nil, klass = self) do
      where("(#{klass.table_name}.#{date_key}, #{klass.table_name}.id) < (?, ?)", before_date, before_id) if before_date.present?
    end

    scope :paginate, -> (pagination_params, pagination_key = :id, klass = self) do
      if pagination_params[:page].present?
        page(pagination_params[:page]).per(pagination_params[:count])
      elsif pagination_key == :id
        since(pagination_params[:since_id], klass).max(pagination_params[:max_id], klass).order(klass.arel_table[pagination_key].desc, klass.arel_table[pagination_key].desc).limit(pagination_params[:count])
      else
        after_date(pagination_params[:after_date], pagination_key, pagination_params[:after_id], klass)
        .before_date(pagination_params[:before_date], pagination_key, pagination_params[:before_id], klass)
        .order(klass.arel_table[pagination_key].desc, klass.arel_table[pagination_key].desc)
        .limit(pagination_params[:count])
      end
    end

    scope :page_paginate, -> (pagination_params) do
      if pagination_params[:page].present?
        page(pagination_params[:page]).per(pagination_params[:count])
      elsif pagination_params[:max_id] || pagination_params[:since_id] || pagination_params[:after_date] || pagination_params[:before_date]
        raise MorselErrors::InvalidPaginationParams
      else
        limit(pagination_params[:count])
      end
    end
  end
end
