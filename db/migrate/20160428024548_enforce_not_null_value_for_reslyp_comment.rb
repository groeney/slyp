class EnforceNotNullValueForReslypComment < ActiveRecord::Migration
  def up
    Reslyp.find_each do |reslyp|
      if reslyp.comment.nil?
        reslyp.comment = ""
        reslyp.save!
      end
    end
    change_column :reslyps, :comment, :string, :null => false
  end

  def down
    change_column :reslyps, :comment, :string
  end
end
