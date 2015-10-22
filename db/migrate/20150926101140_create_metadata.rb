class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.integer :user_id
      t.string  :product
      t.string  :manufacturer
      t.string  :brand
      t.string  :model
      t.string  :device
      t.string  :display
      t.string  :serial
      t.string  :os
      t.string  :os_codename
      t.integer :os_version
      t.timestamps null: false
    end
  end
end
