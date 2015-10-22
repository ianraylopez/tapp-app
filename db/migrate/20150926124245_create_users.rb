class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer   :twitter_id
      t.string    :name
      t.string    :screen_name
      t.string    :location
      t.text      :description
      t.boolean   :is_contributors_enabled
      t.string    :profile_image_url
      t.string    :profile_image_url_https
      t.boolean   :is_default_profile_image
      t.string    :url
      t.boolean   :is_protected
      t.integer   :followers_count
      t.integer   :status
      t.string    :profile_background_color
      t.string    :profile_text_color
      t.string    :profile_link_color
      t.string    :profile_sidebar_fill_color
      t.string    :profile_sidebar_border_color
      t.string    :profile_use_background_image
      t.boolean   :is_default_profile
      t.boolean   :show_all_inline_media
      t.integer   :friends_count
      t.datetime  :created_at
      t.integer   :favourites_count
      t.integer   :utc_offset
      t.string    :time_zone
      t.string    :profile_background_image_url
      t.string    :profile_background_image_url_https
      t.boolean   :profile_background_tiled      
      t.string    :language
      t.integer   :statuses_count
      t.boolean   :is_geo_enabled
      t.boolean   :is_verified
      t.boolean   :translator
      t.integer   :listed_count
      t.boolean   :is_follow_request_sent
      t.timestamps null: false
    end
    add_index(:users, :screen_name)
  end
end
