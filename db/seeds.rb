# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

user = User.create! :email => 'ghost@example.com', :password => 'secret'

ghostwriter = Project.create! :title => 'GhostWriter', :permalink => 'ghostwriter'

user.assignments.create! :project => ghostwriter

english = ghostwriter.locales.create! :code => 'en'

german  = ghostwriter.locales.create! :code => 'de'

Token.delete_all
token0  = ghostwriter.tokens.create! :raw => 'this.is.a.test'
token1  = ghostwriter.tokens.create! :raw => 'this.is.a.second.test'

Translation.delete_all
Translation.create! [ { :locale => english, :token => token0, :content => 'This is a test.' },
                      { :locale => german,  :token => token0, :content => 'Dies ist ein Test.' },
                      { :locale => english, :token => token1, :content => 'This is a second test.' },
                      { :locale => german,  :token => token1, :content => 'Dies ist ein 2. Test.' } ]
