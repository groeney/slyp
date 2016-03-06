class ChangeTypeToSlypType < ActiveRecord::Migration
  def change
    rename_column :slyps, :type, :slyp_type
  end
end
