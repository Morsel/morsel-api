web: bundle exec puma -p $PORT -e ${RACK_ENV:-development} -C ./config/puma.rb
worker: bundle exec sidekiq -q default -q carrierwave
