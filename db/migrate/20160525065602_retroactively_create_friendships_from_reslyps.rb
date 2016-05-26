class RetroactivelyCreateFriendshipsFromReslyps < ActiveRecord::Migration
  def up
    Reslyp.find_each do |reslyp|
      reslyp.befriend
    end
  end
end
