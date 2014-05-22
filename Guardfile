guard :bundler do
  watch('Gemfile')
end

guard 'rails' do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
end

guard :rubocop, notification: true, cli: ['--config', '.rubocop.yml', '--rails'] do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard 'rails_best_practices' do
  watch(%r{^app/(.+)\.rb$})
end

guard 'rspec', cmd: 'zeus rspec --drb --format Fuubar --color', all_after_pass: false, all_on_start: false, failed_mode: :keep do
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }

  watch(%r{^app/controllers/(.+)\.rb})                { |m| "spec/requests/#{m[1]}_spec.rb" }
  watch(%r{^app/decorators/(.+)_decorator\.rb$})      { |m| "spec/requests/#{m[1]}_controller_spec.rb" }
  watch(%r{^app/views/(.+)/(.+)\.rabl$})                 { |m| "spec/requests/#{m[1]}_controller_spec.rb" }

  watch(%r{^lib/(.+)\.rb$})      { |m| "spec/lib/#{m[1]}_spec.rb" }

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/factories/(.+)\.rb$})
  watch(%r{^spec/requests/support/views/(.+)_view\.rb$}) { |m| "spec/requests/#{m[1]}_controller_spec.rb" }

  watch('app/controllers/application_controller.rb')  { "spec/requests" }
end

guard 'brakeman', run_on_start: true do
  watch(%r{^app/.+\.(erb|haml|rhtml|rb)$})
  watch(%r{^config/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('Gemfile')
end

guard :shell do
  watch(%r{^Gemfile|Gemfile.lock$}) { system('bundle-audit')}
  watch('db/schema.rb') { system('rake annotate')}
end

guard 'sidekiq', environment: 'development' do
  watch(%r{^workers/(.+)\.rb$})
end
