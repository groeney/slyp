class AddUserToReslyp < ActiveRecord::Migration
  def change
    add_column :reslyps, :user_id, :integer, null: false
  end
end
