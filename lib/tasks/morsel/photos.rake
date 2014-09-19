require 'rake'

namespace :morsel do
  desc 'Recreate and reprocess the photos for the specified Class.'
  task reprocess_photos: :environment do
    recreate_and_reprocess_class_photos(Item)
    recreate_and_reprocess_class_photos(User)
  end

  def recreate_and_reprocess_class_photos(klass)
    $stdout.sync = true
    puts "Total #{klass}: #{klass.all.count}"
    klass.all.each do |k|
      if k.photo.nil?
        print ' '
        next
      end
      begin
        k.process_photo_upload = true # only if you use carrierwave_backgrounder
        k.photo.cache_stored_file!
        k.photo.retrieve_from_cache!(k.photo.cache_name)
        k.photo.recreate_versions!
        k.save!
        print '.'
      rescue => e
        puts  "ERROR: #{klass}: #{k.id} -> #{e}"
      end
    end
  end
end
