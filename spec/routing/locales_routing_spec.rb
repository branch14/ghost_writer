require "spec_helper"

describe LocalesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/locales" }.should route_to(:controller => "locales", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/locales/new" }.should route_to(:controller => "locales", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/locales/1" }.should route_to(:controller => "locales", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/locales/1/edit" }.should route_to(:controller => "locales", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/locales" }.should route_to(:controller => "locales", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/locales/1" }.should route_to(:controller => "locales", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/locales/1" }.should route_to(:controller => "locales", :action => "destroy", :id => "1")
    end

  end
end
