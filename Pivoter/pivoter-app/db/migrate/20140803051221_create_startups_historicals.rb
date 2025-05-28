class CreateStartupsHistoricals < ActiveRecord::Migration
  def change
    create_table :startups_historicals do |t|
      t.string :name
      t.string :webpage
      t.text :description
      t.string :videopitch
      t.string :achievements
      t.string :logo
      t.integer :user_id
      t.string :country
      t.string :status
      t.string :category
      t.string :stage
      t.integer :pivot_counter
      t.string :audit_action
      t.date :audit_date

      t.timestamps
    end
  end
end
