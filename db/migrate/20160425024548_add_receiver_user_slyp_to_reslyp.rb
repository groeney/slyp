class AddReceiverUserSlypToReslyp < ActiveRecord::Migration
  def change
    add_column :reslyps, :recipient_user_slyp_id, :integer, null: false
  end
end
