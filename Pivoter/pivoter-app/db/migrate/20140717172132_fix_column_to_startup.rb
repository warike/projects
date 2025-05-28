class FixColumnToStartup < ActiveRecord::Migration
  def change
  	rename_column :startups, :achievments, :achievements
  end
end
