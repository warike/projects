class FixColumnStartups < ActiveRecord::Migration
  def change
      rename_column :startups, :description, :pitch
  end
end
