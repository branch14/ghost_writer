require 'spec_helper'

describe "translations/new.html.erb" do
  before(:each) do
    assign(:translation, stub_model(Translation).as_new_record)
  end

  it "renders new translation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => translations_path, :method => "post" do
    end
  end
end
