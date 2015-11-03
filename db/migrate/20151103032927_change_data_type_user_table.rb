class ChangeDataTypeUserTable < ActiveRecord::Migration
  def change
  	change_column :users, :twitter_id, :bigint
  end
end
