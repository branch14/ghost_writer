require File.expand_path('../../spec_helper', __FILE__)

describe Project do

  context "a valid project" do 

    let(:project) { Factory(:project) }

    it "should be valid" do
      project.should be_valid
    end

    it "should validate presence of title" do
      project.title = nil
      project.should_not be_valid
      project.errors[:title].should_not be_empty
    end

    #pending "should provide a list of remaining locales" do
    #  
    #end

    #pending "should accept nested attributes for locales" do
    #  #project.should be_respond_to(:locales_attributes)
    #end
    
    it 'should return aggregated translation' do
      project.locales.create :code => 'en'
      project.should have(1).locale

      token = project.tokens.create :raw => 'this.is.a.test'
      project.should have(1).token
      token.should have(1).translation

      token.translations.first.update_attributes(:content => 'This is a test.')
      expected = { 'en' => { 'this' => { 'is' => { 'a' => { 'test' => 'This is a test.' }}}}}
      project.aggregated_translations.should == expected
    end

    it 'should return aggregated translations' do
      project.locales.create :code => 'en'
      project.should have(1).locale

      token0 = project.tokens.create :raw => 'this.is.a.test'
      token1 = project.tokens.create :raw => 'this.is.another.test'
      project.should have(2).token
      token0.should have(1).translation
      token1.should have(1).translation

      token0.translations.first.update_attributes(:content => 'This is a test.')
      token1.translations.first.update_attributes(:content => 'This is another test.')
      expected = { 'en' => { 'this' => { 'is' => 
            { 'a' => { 'test' => 'This is a test.' },
              'another' => { 'test' => 'This is another test.' }}}}}
      project.aggregated_translations.should == expected
    end

  end


end
