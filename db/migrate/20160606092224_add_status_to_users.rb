class AddStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :status, :integer, default: 0, null: false
    User.find_each do |user|
      if user.invitation_pending?
        user.invited!
      end
    end
  end
end
