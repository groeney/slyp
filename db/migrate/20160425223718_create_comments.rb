class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :reslyp_id, null: false
      t.integer :sender_id, null: false
      t.string  :comment, null: false
    end
  end
end
