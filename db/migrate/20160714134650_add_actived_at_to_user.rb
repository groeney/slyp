class AddActivedAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :activated_at, :timestamp, default: Time.now
  end
end
