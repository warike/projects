require 'spec_helper'

describe "entries/edit" do
  before(:each) do
    @entry = assign(:entry, stub_model(Entry,
      :title => "MyString",
      :type => "",
      :url => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", entry_path(@entry), "post" do
      assert_select "input#entry_title[name=?]", "entry[title]"
      assert_select "input#entry_type[name=?]", "entry[type]"
      assert_select "input#entry_url[name=?]", "entry[url]"
      assert_select "input#entry_description[name=?]", "entry[description]"
    end
  end
end
