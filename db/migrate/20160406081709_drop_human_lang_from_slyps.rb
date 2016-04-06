class DropHumanLangFromSlyps < ActiveRecord::Migration
  def change
    remove_column :slyps, :human_lang, :string
  end
end
