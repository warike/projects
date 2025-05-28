class AddCountryToUser < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :startups, :country, :string
  end
end
