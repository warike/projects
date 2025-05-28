require 'spec_helper'

describe "entries/new" do
  before(:each) do
    assign(:entry, stub_model(Entry,
      :title => "MyString",
      :type => "",
      :url => "MyString",
      :description => "MyString"
    ).as_new_record)
  end

  it "renders new entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", entries_path, "post" do
      assert_select "input#entry_title[name=?]", "entry[title]"
      assert_select "input#entry_type[name=?]", "entry[type]"
      assert_select "input#entry_url[name=?]", "entry[url]"
      assert_select "input#entry_description[name=?]", "entry[description]"
    end
  end
end
