require 'spec_helper'

describe "media/index" do
  before(:each) do
    assign(:media, [
      stub_model(Medium,
        :type => "Type",
        :url => "Url",
        :description => "Description",
        :title => "Title"
      ),
      stub_model(Medium,
        :type => "Type",
        :url => "Url",
        :description => "Description",
        :title => "Title"
      )
    ])
  end

  it "renders a list of media" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
