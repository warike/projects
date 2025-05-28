class AddStatusToPivot < ActiveRecord::Migration
  def change
    add_column :pivots, :status, :boolean
  end
end
