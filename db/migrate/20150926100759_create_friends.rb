class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer   :user_id
      t.integer   :friend_id
      t.datetime  :friendship_dt
    end
  end
end
