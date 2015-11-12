class ChangeDataTypeUserAppsTable < ActiveRecord::Migration
  def change
  	change_column :user_apps, :user_id, :bigint
  end
end