class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer   :user_id
      t.integer   :follower_id
      t.datetime  :friendship_dt
    end
  end
end
