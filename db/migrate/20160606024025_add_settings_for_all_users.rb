class AddSettingsForAllUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify_reslyp, :boolean, default: true, null: false
    add_column :users, :notify_activity, :boolean, default: true, null: false
    add_column :users, :cc_me_on_email_reslyp, :boolean, default: true, null: false
    add_column :users, :weekly_summary, :boolean, default: true, null: false
    add_column :users, :searchable, :boolean, default: true, null: false
  end
end
