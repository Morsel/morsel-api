require 'rake'
require_relative '../../app/workers/collage_worker'
namespace :schedual_morsel do
  desc 'Get Schedual morsel for publish'
  task publish_morsel: :environment do
    morsels = Morsel.where('schedual_date <= ? and schedual_date IS NOT ? and draft = ?',Time.now.strftime("%Y-%m-%d %H:%M"),nil,true)
    morsels.each do |morsel|
      PublishMorsel.call(
        morsel: morsel,
        morsel_params: nil,
        social_params: {
          post_to_facebook: true,
          post_to_twitter: true
        },
        should_republish: false
      )
    #CollageWorker.perform_async(morsel_id: morsel.id,place_id: 0,user_id: 3,post_to_facebook: false,post_to_twitter: false)
    end
  end
end
