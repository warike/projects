require 'spec_helper'

describe "media/edit" do
  before(:each) do
    @medium = assign(:medium, stub_model(Medium,
      :type => "",
      :url => "MyString",
      :description => "MyString",
      :title => "MyString"
    ))
  end

  it "renders the edit medium form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", medium_path(@medium), "post" do
      assert_select "input#medium_type[name=?]", "medium[type]"
      assert_select "input#medium_url[name=?]", "medium[url]"
      assert_select "input#medium_description[name=?]", "medium[description]"
      assert_select "input#medium_title[name=?]", "medium[title]"
    end
  end
end
