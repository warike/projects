class CreatePivots < ActiveRecord::Migration
  def change
    create_table :pivots do |t|
      t.references :startup, index: true
      t.date :start_date
      t.date :finish_date

      t.timestamps
    end
  end
end
