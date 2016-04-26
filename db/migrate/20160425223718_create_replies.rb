class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.integer :reslyp_id, null: false
      t.integer :sender_id, null: false
      t.string  :reply, null: false
    end
  end
end
