class DeleteFromREview < ActiveRecord::Migration
  def change

  	remove_column :reviews, :date_data
  end
end
