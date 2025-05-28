class AddStuffsToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :order, :integer
  end
end
