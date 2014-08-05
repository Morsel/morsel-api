class MorselMrslDecorator < SimpleDelegator
  def generate_mrsl_links!
    Mrslable.mrsl_mediums.each do |medium|
      unless self.send(medium)
        url = medium.include?('media') ? self.media_url : self.url
        self.send("#{medium}=", Mrsl.shorten(url, medium.to_s.sub('_mrsl', ''), 'share', "morsel-#{id}"))
      end
    end

    save if changed?
  end

  private

  def media_url
    # http://media.eatmorsel.com/morsels/1
    "#{Settings.morsel.media_url}/morsels/#{id}"
  end

end
