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
    pending "should provide a list of remaining locales" do
      
    end
    pending "should accept nested attributes for locales" do
      #project.should be_respond_to(:locales_attributes)
    end
  end


end
