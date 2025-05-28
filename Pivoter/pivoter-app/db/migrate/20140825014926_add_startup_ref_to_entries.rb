class AddStartupRefToEntries < ActiveRecord::Migration
  def change
    add_reference :entries, :startup, index: true
  end
end
