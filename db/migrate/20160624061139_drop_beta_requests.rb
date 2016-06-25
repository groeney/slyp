class DropBetaRequests < ActiveRecord::Migration
  def change
    drop_table :beta_requests
  end
end
