class ChangeColumnNameOnReslyps < ActiveRecord::Migration
  def change
    rename_column :reslyps, :sender_userslyp_id, :user_slyp_id
  end
end
