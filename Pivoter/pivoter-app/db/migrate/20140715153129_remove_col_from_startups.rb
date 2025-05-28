class RemoveColFromStartups < ActiveRecord::Migration
  def change

  	remove_column :startups, :user_id
  	
  end
end
