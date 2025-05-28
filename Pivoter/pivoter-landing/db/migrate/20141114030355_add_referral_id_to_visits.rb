class AddReferralIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :referralID, :string
  end
end
