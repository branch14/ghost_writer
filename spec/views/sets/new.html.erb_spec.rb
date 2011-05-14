require 'spec_helper'

describe "sets/new.html.erb" do
  before(:each) do
    assign(:set, stub_model(Set).as_new_record)
  end

  it "renders new set form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sets_path, :method => "post" do
    end
  end
end
