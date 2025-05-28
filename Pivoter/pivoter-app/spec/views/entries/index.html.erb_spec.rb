require 'spec_helper'

describe "entries/index" do
  before(:each) do
    assign(:entries, [
      stub_model(Entry,
        :title => "Title",
        :type => "Type",
        :url => "Url",
        :description => "Description"
      ),
      stub_model(Entry,
        :title => "Title",
        :type => "Type",
        :url => "Url",
        :description => "Description"
      )
    ])
  end

  it "renders a list of entries" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
