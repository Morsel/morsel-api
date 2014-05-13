module Mrsl
  # http://www.eatmorsel.com/some/url?utm_source=source&utm_medium=medium&utm_campaign=campaign&utm_keyword=mrsl
  def self.shorten(url, source, medium, campaign)
    new_url = Addressable::URI.parse(url)
    new_url.query_values = (new_url.query_values || {}).merge(utm_source: source, utm_medium: medium, utm_campaign: campaign, utm_keyword: 'mrsl')

    Bitly.client.shorten(new_url.to_s).short_url
  end
end
