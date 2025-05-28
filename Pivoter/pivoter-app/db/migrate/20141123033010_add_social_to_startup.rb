class AddSocialToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :twitter_acc, :string
    add_column :startups, :facebook_acc, :string
  end
end
