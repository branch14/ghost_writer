require 'spec_helper'

describe "locales/new.html.erb" do
  before(:each) do
    assign(:locale, stub_model(Locale).as_new_record)
  end

  it "renders new locale form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => locales_path, :method => "post" do
    end
  end
end
