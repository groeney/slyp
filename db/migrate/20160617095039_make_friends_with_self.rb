class MakeFriendsWithSelf < ActiveRecord::Migration
  def change
    User.find_each do |user|
      user.befriend(user.id, false)
    end
  end
end
