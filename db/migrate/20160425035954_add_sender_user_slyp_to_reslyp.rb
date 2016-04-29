class AddSenderUserSlypToReslyp < ActiveRecord::Migration
  def change
    add_column :reslyps, :sender_user_slyp_id, :integer
    Reslyp.find_each do |reslyp|
      reslyp.sender_user_slyp_id = reslyp.user.user_slyps.find_by({
        :slyp_id => reslyp.slyp_id
        }).id
      reslyp.save!
    end
    change_column :reslyps, :sender_user_slyp_id, :integer, :null => false
  end
end
