class CreateBetaRequests < ActiveRecord::Migration
  def change
    create_table :beta_requests do |t|
      t.string :email, null: false
      t.boolean :invited, null: false, default: false
      t.boolean :signed_up, null: false, default: false

      t.timestamps null: false
    end
  end
end
