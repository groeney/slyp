class ChangeUserSlypToRecipientUserSlypOnReslyp < ActiveRecord::Migration
  def change
    rename_column :reslyps, :user_slyp_id, :recipient_user_slyp_id
  end
end
