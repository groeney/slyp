class AddSendReslypEmailFromToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_reslyp_email_from, :string
    User.find_each do |u|
      u.update(send_reslyp_email_from: u.email)
    end
  end
end
