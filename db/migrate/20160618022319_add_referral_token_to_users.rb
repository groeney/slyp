class AddReferralTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :referral_token, :string
    User.find_each do |user|
      user.save
    end
  end
end
