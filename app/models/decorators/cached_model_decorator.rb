class CachedModelDecorator < SimpleDelegator
  def cache_key_for_has_many(relation)
    if send(relation).count > 0
      "#{relation}-#{[send(relation).count(:updated_at), send(relation).maximum(:updated_at)].map(&:to_i).join('-')}"
    else
      "no-#{relation}"
    end
  end
end
