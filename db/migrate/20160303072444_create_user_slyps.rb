class CreateUserSlyps < ActiveRecord::Migration
  def change
    create_table :user_slyps do |t|
      t.integer :slyp_id, null: false
      t.integer :user_id, null: false
      t.boolean :favourite, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
