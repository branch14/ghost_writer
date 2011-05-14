require "spec_helper"

describe TranslationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/translations" }.should route_to(:controller => "translations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/translations/new" }.should route_to(:controller => "translations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/translations/1" }.should route_to(:controller => "translations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/translations/1/edit" }.should route_to(:controller => "translations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/translations" }.should route_to(:controller => "translations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/translations/1" }.should route_to(:controller => "translations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/translations/1" }.should route_to(:controller => "translations", :action => "destroy", :id => "1")
    end

  end
end
