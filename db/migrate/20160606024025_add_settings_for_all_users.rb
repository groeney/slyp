class AddSettingsForAllUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify_friend_joined, :integer, default: 0, null: false
    add_column :users, :notify_reslyp, :integer, default: 0, null: false
    add_column :users, :notify_replies, :integer, default: 0, null: false
    add_column :users, :weekly_summary, :boolean, default: true, null: false
  end
end
