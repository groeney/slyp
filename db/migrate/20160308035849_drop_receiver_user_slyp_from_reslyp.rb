class DropReceiverUserSlypFromReslyp < ActiveRecord::Migration
  def change
    remove_column :reslyps, :receiver_user_slyp_id, :integer
  end
end
