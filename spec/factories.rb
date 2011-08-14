Factory.define :project do |f|
  f.title 'Project title'
  f.permalink 'asdfgh'
end

Factory.define :locale do |f|
  f.association :project
  f.code 'en'
end

Factory.define :token do |f|
  f.association :project
end

Factory.define :translation do |f|
  f.association :locale
  f.association :token
end

Factory.define :user do |f|
  f.sequence(:email) { |n| "user#{n}@example.com" }
  f.password "joshua"
  f.password_confirmation "joshua"
end
