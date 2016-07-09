class ChangeReslypFromToSelfEmail < ActiveRecord::Migration
  def change
    User.find_each do |u|
      u.update(send_reslyp_email_from: u.email)
    end
  end
end
