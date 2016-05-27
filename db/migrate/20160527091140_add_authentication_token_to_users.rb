class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :authentication_token, :string
    User.find_each do |user|
      user.save
    end
  end

  def down
    remove_column :users, :authentication_token, :string
  end
end
