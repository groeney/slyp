class CreateBetaRequests < ActiveRecord::Migration
  def change
    create_table :beta_requests do |t|
      t.boolean :invited, null: false, default: false
      t.boolean :signed_up, null: false, default: false
      t.string  :email, null: false
      t.string  :first_name, null: false
      t.string  :last_name

      t.timestamps null: false
    end
  end
end
