class ShortenURL
  include Service

  attribute :url, String
  attribute :utm, Hash

  validate :valid_url?

  # http://www.eatmorsel.com/some/url?utm_source=source&utm_medium=medium&utm_campaign=campaign&utm_keyword=mrsl
  def call
    parsed_url = Addressable::URI.parse(url)
    # NOTE: Should eventually check for utms before sending them. Currently the mrsl links generated during the publish flow always have all utms
    parsed_url.query_values = (parsed_url.query_values || {}).merge(utm_source: safe_utm[:source], utm_medium: safe_utm[:medium], utm_campaign: safe_utm[:campaign], utm_keyword: 'mrsl')

    bitly_client.shorten(parsed_url.to_s).short_url
  end

  private

  def valid_url?
    valid_url = URI.parse(url) rescue false
    errors.add(:url, 'is not valid') unless valid_url.kind_of?(URI::HTTP) || valid_url.kind_of?(URI::HTTPS)
  end

  def bitly_client
    @bitly_client ||= Bitly.client
  end

  def safe_utm
    @safe_utm ||= utm ? utm.symbolize_keys : {}
  end
end
