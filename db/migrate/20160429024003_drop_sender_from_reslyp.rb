class DropSenderFromReslyp < ActiveRecord::Migration
  def change
    remove_column :reslyps, :sender, :boolean
  end
end
