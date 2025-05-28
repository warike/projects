class AddPivotCounterToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :pivot_counter, :integer
  end
end
