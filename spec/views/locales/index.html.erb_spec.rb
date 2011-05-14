require 'spec_helper'

describe "locales/index.html.erb" do
  before(:each) do
    assign(:locales, [
      stub_model(Locale),
      stub_model(Locale)
    ])
  end

  it "renders a list of locales" do
    render
  end
end
