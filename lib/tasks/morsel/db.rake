require 'rake'

namespace :morsel do
  namespace :db do
    desc 'Capture the database from Production'
    task capture: :environment do
      puts 'Capturing Database'
      heroku('pgbackups:capture', 'morsel-api')
    end

    desc 'Downloads the latest backup'
    task dump: :environment do
      puts 'Dumping latest backup'
      prod_backup_url = heroku('pgbackups:url', 'morsel-api')
      `curl -o #{Rails.root}/tmp/latest_production.dump "#{prod_backup_url}"`
    end

    desc 'Imports the latest downloaded backup to morsel_development'
    task import: :environment do
      puts 'Importing latest dump'
      `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U root -d morsel_development #{Rails.root}/tmp/latest_production.dump`
    end

    desc 'Dumps production data to staging'
    task prod_to_stag: :environment do
      prod_backup_url = heroku('pgbackups:url', 'morsel-api')
      heroku("pgbackups:restore DATABASE_URL #{prod_backup_url} --confirm=morsel-api-staging", 'morsel-api-staging')
      # heroku pgbackups:restore DATABASE_URL `heroku pgbackups:url --app=morsel-api`
    end
  end

  def heroku(command, app = 'morsel-api-staging')
    `GEM_HOME='' BUNDLE_GEMFILE='' GEM_PATH='' RUBYOPT='' /usr/local/heroku/bin/heroku #{command} --app=#{app}`
  end
end
