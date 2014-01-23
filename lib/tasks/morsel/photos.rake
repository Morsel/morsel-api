require 'rake'

namespace :morsel do
  desc 'Recreate and reprocess the photos for the specified Class.'
  task :reprocess_photos => :environment do
    recreate_and_reprocess_class_photos(Morsel)
    recreate_and_reprocess_class_photos(User)
  end

  def recreate_and_reprocess_class_photos(klass)
    klass.all.each do |k|
      next if k.photo.nil?
      begin
        # k.process_photo_upload = true # only if you use carrierwave_backgrounder
        k.photo.cache_stored_file!
        k.photo.retrieve_from_cache!(k.photo.cache_name)
        k.photo.recreate_versions!
        k.save!
      rescue => e
        puts  "ERROR: #{klass.to_s}: #{k.id} -> #{e.to_s}"
      end
    end
  end
end

