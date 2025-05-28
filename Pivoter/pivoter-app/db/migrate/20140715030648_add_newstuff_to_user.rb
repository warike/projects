class AddNewstuffToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :name, :string
    add_column :users, :lastname, :string
    add_column :users, :address, :string
    add_column :users, :phone_number, :string
    add_column :users, :description, :text
    add_column :users, :profession, :string
    add_column :users, :achievments, :string
    add_column :users, :datebirth, :date
    add_column :users, :interest, :string
  end
end
