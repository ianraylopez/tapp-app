class CreateUserApps < ActiveRecord::Migration
  def change
    create_table :user_apps do |t|
      t.integer   :user_id
      t.integer   :app_id
      t.timestamps null: false
    end
  end
end
