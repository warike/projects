class AddCountryToEvent < ActiveRecord::Migration
  def change
    add_column :ahoy_events, :country, :string
  end
end
