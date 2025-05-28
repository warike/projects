class AddRateNameToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :ratename, :integer
    add_column :reviews, :score, :integer
  end
end
