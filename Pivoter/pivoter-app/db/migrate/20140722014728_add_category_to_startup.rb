class AddCategoryToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :category, :string
  end
end
