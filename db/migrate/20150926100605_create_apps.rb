class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string  :name
      t.string  :icon_url
      t.string  :link
      t.string  :category
      t.text    :description
      t.timestamps null: false
    end
    add_index(:apps, :name)
  end
end
