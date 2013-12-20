# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

MorselApp::Application.load_tasks

task :annotate do
  exec 'annotate --format markdown --force'
end
