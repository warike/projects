class AddStatusToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :status, :string
  end
end
