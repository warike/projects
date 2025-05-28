class AddStartupToEvent < ActiveRecord::Migration
  def change
    add_reference :ahoy_events, :startup, index: true
  end
end
