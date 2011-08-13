# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'compass' do
  watch(/^src\/(.*)\.s[ac]ss/)
end

guard 'rspec', :version => 2 do
  watch(/^spec\/(.*)_spec.rb/)
  watch(/^lib\/(.*)\.rb/)                              { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper.rb/)                       { "spec" }
  
  # Rails example
  watch(/^app\/(.*)\.rb/)                              { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^lib\/(.*)\.rb/)                              { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/^config\/routes.rb/)                          { "spec/routing" }
  watch(/^app\/controllers\/application_controller.rb/) { "spec/controllers" }
  watch(/^spec\/factories.rb/)                         { "spec/models" }
end

guard 'spork' do
  watch(/config\/application.rb/)
  watch(/config\/environment.rb/)
  watch(/^config\/environments\/.*\.rb$/)
  watch(/^config\/initializers\/.*\.rb$/)
  watch(/spec\/spec_helper.rb/)
end

guard 'mozrepl' do
  watch(/app\/.+\.(erb|haml)/)  
  watch(/app\/helpers\/.+\.rb/)
  watch(/public\/(.+\.(css|js|html))/) { |m| m[1] }
  watch(/config\/locales\/.+\.yml/)
end

### or with options...
# guard 'mozrepl', :host => 'localhost', :port => 4242, :verbose => true do
#   ...

guard 'passenger' do
  watch('Gemfile')
  watch(/^lib\/.*\.rb$/)
  watch(/^config\/.*\.rb$/)
end

