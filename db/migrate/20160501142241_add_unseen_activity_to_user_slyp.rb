class AddUnseenActivityToUserSlyp < ActiveRecord::Migration
  def change
    add_column :user_slyps, :unseen_activity, :boolean, null: false, default: false
  end
end
