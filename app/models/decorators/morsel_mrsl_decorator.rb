class MorselMrslDecorator < SimpleDelegator
  def generate_mrsl_links!
    Mrslable.mrsl_sources.each do |source|
      unless self.send(source)
        url = source.to_s.include?('media') ? self.media_url : self.url
        service = ShortenURL.call(
          url:url,
          utm: {
            source: source.to_s.sub('_mrsl', ''),
            medium: 'share',
            campaign: "morsel-#{id}"
          }
        )
        self.send("#{source}=", service.response)
      end
    end

    save if changed?
  end

  def media_url
    # http://media.eatmorsel.com/morsels/1
    "#{Settings.morsel.media_url}/morsels/#{id}"
  end
end
