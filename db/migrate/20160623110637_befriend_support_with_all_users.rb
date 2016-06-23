class BefriendSupportWithAllUsers < ActiveRecord::Migration
  def change
    User.find_each do |user|
      support = User.find_by(email: "support@slyp.io")
      user.befriend(support.id, true) unless support.nil?
    end
  end
end
