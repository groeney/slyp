class ChangeUserSlypToSenderUserSlypOnReslyp < ActiveRecord::Migration
  def change
    rename_column :reslyps, :user_slyp_id, :sender_user_slyp_id
  end
end
