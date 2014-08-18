class CachedSerializer
  attr_reader :relation, :scope, :serializer, :options

  def initialize(relation, options = {})
    @relation           = relation
    @options            = options
    @scope              = options.fetch(:scope)
    @serializer         = options.fetch(:serializer)
  end

  delegate :as_json, :to_json, to: :perforated_cache

  def perforated_cache
    Perforated::Cache.new(wrapped_models, KeyStrategy.new(scope))
  end

  private

  def wrapped_models
    relation.map { |model| serializer.new(model, options) }
  end

  KeyStrategy = Struct.new(:scope) do
    def expand_cache_key(object, suffix)
      args = object.respond_to?(:object) ? [object.object] : [object]
      args << scope.id if scope
      args << suffix

      ActiveSupport::Cache.expand_cache_key(args)
    end
  end
end
