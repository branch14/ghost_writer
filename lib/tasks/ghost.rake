require 'json'
require 'yaml'

namespace :ghost do
  task :parse, :file do |t, args|
    data = File.open(args[:file], 'r').read
    puts JSON.parse(data).to_yaml
  end
end 
