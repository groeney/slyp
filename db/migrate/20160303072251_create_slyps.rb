class CreateSlyps < ActiveRecord::Migration
  def change
    create_table :slyps do |t|
      t.string :title
      t.string :author
      t.date :date
      t.string :display_url
      t.string :icon
      t.string :site_name
      t.string :type
      t.string :human_lang
      t.text :text
      t.integer :duration
      t.integer :word_count
      t.text :html
      t.string :url, null: false
      t.string :raw_url, null: false
      t.timestamps null: false
    end
  end
end
