require 'spec_helper'

describe "locales/edit.html.erb" do
  before(:each) do
    @locale = assign(:locale, stub_model(Locale))
  end

  it "renders the edit locale form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => locales_path(@locale), :method => "post" do
    end
  end
end
