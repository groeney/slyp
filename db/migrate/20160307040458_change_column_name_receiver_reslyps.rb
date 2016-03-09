class ChangeColumnNameReceiverReslyps < ActiveRecord::Migration
  def change
    rename_column :reslyps, :receiver_userslyp_id, :receiver_user_slyp_id
  end
end
