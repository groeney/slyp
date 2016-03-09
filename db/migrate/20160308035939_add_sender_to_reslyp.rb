class AddSenderToReslyp < ActiveRecord::Migration
  def change
    add_column :reslyps, :sender, :boolean, null: false
  end
end
