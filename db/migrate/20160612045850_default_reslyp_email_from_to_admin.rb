class DefaultReslypEmailFromToAdmin < ActiveRecord::Migration
  def change
    change_column :users, :send_reslyp_email_from, :string, default: "admin@slyp.io", null: false
    User.find_each do |u|
      u.update(send_reslyp_email_from: "admin@slyp.io")
    end
  end
end
