web: bundle exec puma -p $PORT -e ${RACK_ENV:-development} -C ./config/puma.rb
worker: bundle exec sidekiq -c 10 -q default -q carrierwave -q rollbar
