require 'json'

namespace :ghost do
  task :parse, :file do |t, args|
    data = File.open(args[:file], 'r').read
    puts JSON.parse(data).ya2yaml(:syck_compatible => true)
  end
end 
