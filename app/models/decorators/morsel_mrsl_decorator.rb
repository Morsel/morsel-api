class MorselMrslDecorator < SimpleDelegator
  def generate_mrsl_links!
    Mrslable.mrsl_mediums.each do |medium|
      self.send("#{medium}=", Mrsl.shorten(self.url, medium.to_s.sub('_mrsl', ''), 'share', "morsel-#{id}")) unless self.send(medium)
    end

    save if changed?
  end
end
