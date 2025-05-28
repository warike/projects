class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :type
      t.string :url
      t.string :description

      t.timestamps
    end
  end
end
