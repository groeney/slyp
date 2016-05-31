class AddSeenToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :seen, :boolean, null: false, default: false
  end
end
