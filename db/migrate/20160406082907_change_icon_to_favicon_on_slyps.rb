class ChangeIconToFaviconOnSlyps < ActiveRecord::Migration
  def change
    rename_column :slyps, :icon, :favicon
  end
end
