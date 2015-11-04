class ChangeDataTypeFriendTable < ActiveRecord::Migration
  def change
  	change_column :friends, :user_id, :bigint
  	change_column :friends, :friend_id, :bigint
  end
end
