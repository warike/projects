require 'spec_helper'

describe "media/new" do
  before(:each) do
    assign(:medium, stub_model(Medium,
      :type => "",
      :url => "MyString",
      :description => "MyString",
      :title => "MyString"
    ).as_new_record)
  end

  it "renders new medium form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", media_path, "post" do
      assert_select "input#medium_type[name=?]", "medium[type]"
      assert_select "input#medium_url[name=?]", "medium[url]"
      assert_select "input#medium_description[name=?]", "medium[description]"
      assert_select "input#medium_title[name=?]", "medium[title]"
    end
  end
end
