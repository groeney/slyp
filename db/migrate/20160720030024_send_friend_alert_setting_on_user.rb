class SendFriendAlertSettingOnUser < ActiveRecord::Migration
  def change
    add_column :users, :send_new_friend_notification, :boolean, default: true
  end
end
