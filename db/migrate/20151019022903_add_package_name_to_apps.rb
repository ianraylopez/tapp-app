class AddPackageNameToApps < ActiveRecord::Migration
  def change
    add_column :apps, :package_name, :string
  end
end
