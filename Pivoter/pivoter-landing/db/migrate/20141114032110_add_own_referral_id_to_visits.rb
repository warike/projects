class AddOwnReferralIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :ownReferralID, :string
  end
end
