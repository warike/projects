class FixColumnEntries < ActiveRecord::Migration
  def change
    rename_column :entries, :order, :show_order
  end
end
