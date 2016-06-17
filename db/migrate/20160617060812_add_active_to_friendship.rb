class AddActiveToFriendship < ActiveRecord::Migration
  def change
    add_column :friendships, :active, :boolean, default: true, null: false
  end
end
