class EnforceNotNullValueForReslypComment < ActiveRecord::Migration
  def up
    change_column :reslyps, :comment, :string, :null => false, default: ""
  end

  def down
    change_column :reslyps, :comment, :string
  end
end
