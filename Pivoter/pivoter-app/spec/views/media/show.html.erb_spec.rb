require 'spec_helper'

describe "media/show" do
  before(:each) do
    @medium = assign(:medium, stub_model(Medium,
      :type => "Type",
      :url => "Url",
      :description => "Description",
      :title => "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/Url/)
    rendered.should match(/Description/)
    rendered.should match(/Title/)
  end
end
