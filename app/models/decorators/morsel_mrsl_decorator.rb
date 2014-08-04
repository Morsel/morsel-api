class MorselMrslDecorator < SimpleDelegator
  def generate_mrsl_links
    Mrslable.mrsl_mediums.each do |medium|
      self.send("#{medium}=", Mrsl.shorten(morsel.url, medium.sub('_mrsl', ''), 'share', "morsel-#{id}")) unless self.send(medium)
    end

    save if changed?
  end
end
