class MorselMrslDecorator < SimpleDelegator
  def generate_mrsl_links
    Mrslable.mrsl_mediums.each do |medium|
      morsel.send("#{medium}=", Mrsl.shorten(morsel.url, medium.sub('_mrsl', ''), 'share', "morsel-#{morsel.id}")) unless morsel.send(medium)
    end

    morsel.save if morsel.changed?
  end
end
