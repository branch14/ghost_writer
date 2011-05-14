require 'spec_helper'

describe "keys/new.html.erb" do
  before(:each) do
    assign(:key, stub_model(Key).as_new_record)
  end

  it "renders new key form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => keys_path, :method => "post" do
    end
  end
end
