class AddReceiverToReslyp < ActiveRecord::Migration
  def change
    add_column :reslyps, :recipient_id, :integer, null: false
  end
end
