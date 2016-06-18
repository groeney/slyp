class RemoveNotNullReqOnReslypComment < ActiveRecord::Migration
  def up
    change_column :reslyps, :comment, :string, :null => true
  end
  def down
    change_column :reslyps, :comment, :string, :null => false
  end
end
