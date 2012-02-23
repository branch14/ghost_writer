require 'spec_helper'

describe "FactoryGirl" do

  describe "factories" do
    specify { Factory.build(:project).should be_valid }
    specify { Factory.build(:locale).should be_valid }
    specify { Factory.build(:token).should be_valid }
    specify { Factory.build(:translation).should be_valid }
  end

  # this test assures that the database is cleaned up before each
  # example.
  describe "a persisted project by factory" do

    before(:each) { Factory(:project) }

    it "should create exactly one project" do
      Project.count.should == 1
    end

    it "and cleanup the database before each test" do
      Project.count.should == 1
    end

  end

end
