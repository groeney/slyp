class CreateReslyps < ActiveRecord::Migration
  def change
    create_table :reslyps do |t|
      t.integer :slyp_id, null: false
      t.integer :sender_userslyp_id, null: false
      t.integer :receiver_userslyp_id, null: false
      t.string :comment

      t.timestamps null: false
    end
  end
end
