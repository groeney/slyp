class DropCommentFromReslyps < ActiveRecord::Migration
  def change
    remove_column :reslyps, :comment, :string
  end
end
