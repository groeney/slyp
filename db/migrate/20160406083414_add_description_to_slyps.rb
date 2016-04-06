class AddDescriptionToSlyps < ActiveRecord::Migration
  def change
    add_column :slyps, :description, :text
  end
end
