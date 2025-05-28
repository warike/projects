class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :pivot, index: true
      t.references :user, index: true
      t.text :comment
      t.date :date_data
      t.integer :ratelogo
      t.integer :ratepitch
      t.integer :ratevideo
      t.integer :rateidea

      t.timestamps
    end
  end
end
