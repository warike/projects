class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.string :name
      t.string :webpage
      t.text :description
      t.string :videopitch
      t.string :achievments
      t.string :logo

      t.timestamps
    end
  end
end
