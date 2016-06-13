class BefriendSelf < ActiveRecord::Migration
  def change
    User.find_each do |user|
      user.befriend(user.id)
    end
  end
end
