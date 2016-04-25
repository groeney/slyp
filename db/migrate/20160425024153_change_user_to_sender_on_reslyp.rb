class ChangeUserToSenderOnReslyp < ActiveRecord::Migration
  def change
    rename_column :reslyps, :user_id, :sender_id
  end
end
