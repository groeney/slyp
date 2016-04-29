class AddRecipientToReslyp < ActiveRecord::Migration
  def up
    add_column :reslyps, :recipient_id, :integer
    Reslyp.find_each do |reslyp|
      if reslyp.sender
        reslyp.destroy()
      else
        reslyp.recipient_id = reslyp.user_slyp.user.id
        reslyp.save!
      end
    end
    change_column :reslyps, :recipient_id, :integer, :null => false
  end

  def down
    remove_column :reslyps, :recipient_id
  end
end
