# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user = User.create! :email => 'ghost@example.com', :password => 'secret'

project = Project.create! :title => 'GhostWriter', :permalink => 'ghostwriter'

user.assignments.create! :project => project

english = project.locales.create! :code => 'en'
german  = project.locales.create! :code => 'de'

# Token.delete_all
tokens0 = project.find_or_create_tokens('this.is.a.test')
tokens1 = project.find_or_create_tokens('this.is.a.second.test')

# Translation.delete_all
Translation.create! [ { :locale => english, :token => tokens0.last,
                        :content => 'This is a test.' },
                      { :locale => german,  :token => tokens0.last,
                        :content => 'Dies ist ein Test.' },
                      { :locale => english, :token => tokens1.last,
                        :content => 'This is a second test.' },
                      { :locale => german,  :token => tokens1.last,
                        :content => 'Dies ist ein 2. Test.' } ]
