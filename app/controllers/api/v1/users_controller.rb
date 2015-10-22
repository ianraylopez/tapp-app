class API::V1::UsersController < ApplicationController

	def create
		@user = User.new()
	    @user.twitter_id = params[:twitter_id]
	    @user.name = params[:name]
	    @user.screen_name = params[:screen_name]
	    @user.location = params[:location]
	    @user.description = params[:description]
	    @user.is_contributors_enabled = params[:is_contributors_enabled]
	    @user.profile_image_url = params[:profile_image_url]
	    @user.profile_image_url_https = params[:profile_image_url_https]
	    @user.is_default_profile_image = params[:is_default_profile_image]
	    @user.url = params[:url]
	    @user.is_protected = params[:is_protected]
	    @user.followers_count = params[:followers_count]
	    @user.status = params[:status]
	    @user.profile_background_color = params[:profile_background_color]
	    @user.profile_text_color = params[:profile_text_color]
	    @user.profile_link_color = params[:profile_link_color]
	    @user.profile_sidebar_fill_color = params[:profile_sidebar_fill_color]
	    @user.profile_sidebar_border_color = params[:profile_sidebar_border_color]
   		@user.profile_use_background_image = params[:profile_use_background_image]
   		@user.is_default_profile = params[:is_default_profile]
   		@user.show_all_inline_media = params[:show_all_inline_media]
   		@user.friends_count = params[:friends_count]
   		@user.created_at = params[:created_at]
   		@user.favourites_count = params[:favourites_count]
   		@user.utc_offset = params[:utc_offset]
   		@user.time_zone = params[:time_zone]
   		@user.profile_background_image_url = params[:profile_background_image_url]
   		@user.profile_background_image_url_https = params[:profile_background_image_url_https]
   		@user.profile_background_tiled = params[:profile_background_tiled]
   		@user.language = params[:language]
   		@user.statuses_count = params[:statuses_count]
   		@user.is_geo_enabled = params[:is_geo_enabled]
   		@user.is_verified = params[:is_verified]
   		@user.translator = params[:translator]
   		@user.listed_count = params[:listed_count]
   		@user.is_follow_request_sent = params[:is_follow_request_sent]
	    
	    respond_to do |format|
	      if @user.save
	        format.json { head :no_content, status: :created }
	      else
	        format.json { render json: @user.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def follow
		# will just use Friend for now. followers can be generated from this table already
		@user = User.where(twitter_id: params[:user_id])
		@followed = User.where(twitter_id: params[:followed_id])

		@friend = Friend.new()
		@friend.user_id = @followed
		@friend.follower_id = @user
		@friend.friendship_dt = Time.now

		respond_to do |format|
	      if @friend.save
	        format.json { head :no_content, status: :created }
	      else
	        format.json { render json: @friend.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def list_following
		@user = User.where(twitter_id: params[:user_id])
		@followings = Friend.where(user_id: params[:user_id])

		@data = []
		@dataset = {}

		@followings.each do | f |
			# get user details here
			@user_details = User.where(twitter_id: f.user_id)
			# get tapped apps
			@user_apps_id = App.where(user_id: f.user_id)
			@user_apps_count = @user_apps_id.length
			# get friends
			@friends = Friend.where(user_id: f.user_id)
			@friends_count = @friends.length
			# get followers
			@followers = Friend.where(friend_id: f.user_id)
			@followers_count = @followers.length

			@dataset = {:name => @user_details.name, :screen_name => @user_details.screen_name, :description => @user_details.description, :count_apps => @user_apps_count, :count_friends => @friends_count, :count_followers => @followers_count}
		end

		@data << @dataset

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :created }
	      else
	        format.json { head :no_content, status: :no_content }
	      end
	    end
	end

	def add_user_app
		@user = User.where(twitter_id: params[:user_id])
		@app = App.where(package_name: params[:package_name])

		if @app.length == 0
			# insert app
			@new_app.name = params[:name]
			@new_app.package_name = params[:package_name]
			@new_app.icon_url = params[:icon_url]
			@new_app.link = params[:link]
			@new_app.category = params[:category]
			@new_app.description = params[:description]
			@new_app.save
			@app_id = @new_app.id
		else
			@app_id = @app.id
		end

		@user_app = UserApp.new()
		@user_app.user_id = @user.twitter_id
		@user_app.app_id = @app_id
		
		respond_to do |format|
	      if @user_app.save
	        format.json { head :no_content, status: :created }
	      else
	        format.json { render json: @user_app.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def feed
		@user = User.where(twitter_id: params[:user_id])
		@followings = Friend.where(user_id: params[:user_id])
	end

	private

		def user_params
			params.require(:user).permit(:twitter_id, :name, :screen_name, :location, :description, :is_contributors_enabled,
				:profile_image_url, :profile_image_url_https, :profile_image_url_https, :is_default_profile_image, :url, 
				:is_protected, :followers_count, :status, :profile_background_color, :profile_text_color, :profile_link_color, 
				:profile_sidebar_fill_color, :profile_sidebar_border_color, :profile_use_background_image, :is_default_profile, 
				:show_all_inline_media, :friends_count, :created_at, :favourites_count, :utc_offset, :time_zone, 
				:profile_background_image_url, :profile_background_image_url_https, :profile_background_tiled, :language,
				:statuses_count, :is_geo_enabled, :is_verified, :translator, :listed_count, :is_follow_request_sent)
		end

		def friend_params
			params.require(:friend).permit(:user_id, :follower_id, :friendship_dt)
		end

		def app_params
			params.require(:app).permit(:name, :package_name, :icon_url, :link, :category, :description)
		end

		def user_apps_params
			params.require(:user_apps).permit(:user_id, :app_id)
		end

    end

end
