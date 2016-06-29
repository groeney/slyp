class DefaultReslypEmailFromToSupport < ActiveRecord::Migration
  def change
    change_column :users, :send_reslyp_email_from, :string, default: "support@slyp.io", null: false
    User.find_each do |u|
      u.update(send_reslyp_email_from: "support@slyp.io")
    end
  end
end
