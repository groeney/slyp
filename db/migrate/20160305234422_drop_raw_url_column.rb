class DropRawUrlColumn < ActiveRecord::Migration
  def change
    remove_column :slyps, :raw_url, :string
  end
end
