class CreateBetaRequests < ActiveRecord::Migration
  def change
    create_table :beta_requests do |t|
      t.boolean :invited, null: false, default: false
      t.boolean :signed_up, null: false, default: false
      t.string  :email, null: false

      t.timestamps null: false
    end
  end
end
