class AddUnseenToUserSlyp < ActiveRecord::Migration
  def change
    add_column :user_slyps, :unseen, :boolean, null: false, default: false
  end
end
