class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :access_key
      t.string :secret_access
    end
  end
end
