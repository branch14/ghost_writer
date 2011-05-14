require 'spec_helper'

describe "sets/edit.html.erb" do
  before(:each) do
    @set = assign(:set, stub_model(Set))
  end

  it "renders the edit set form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sets_path(@set), :method => "post" do
    end
  end
end
