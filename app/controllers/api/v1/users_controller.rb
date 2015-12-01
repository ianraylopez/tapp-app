class API::V1::UsersController < ApplicationController

	require 'google_play_search'
	require 'market_bot'

	def test
		@test = "OK"
		respond_to do |format|
	      if @test
	        format.json { render json: @test, status: :ok }
	      else
	        format.json { render json: @test.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def create_user
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

   		if params[:twitter_id] == nil || params[:twitter_id] == ''
   			respond_to do |format|
   				format.json { render json: "Twitter ID is required.", status: :unprocessable_entity }
   			end
   		else
   			respond_to do |format|
		      if @user.save
		        format.json { render json: "OK", status: :ok }
		      else
		        format.json { render json: @user.errors, status: :unprocessable_entity }
		      end
		    end
   		end	
	    
	end

	def follow
		# will just use Friend for now. followers can be generated from this table already
		@friend = Friend.new()
		@friend.user_id = params[:followed_id]
		@friend.friend_id = params[:twitter_id]
		@friend.friendship_dt = Time.now

		respond_to do |format|
	      if @friend.save
	        format.json { render json: "OK", status: :ok }
	      else
	        format.json { render json: @friend.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def unfollow
		@friendship = Friend.where("user_id = ? AND friend_id = ?", params[:followed_id], params[:twitter_id])

		respond_to do |format|
	      if Friend.destroy(@friendship)
	        format.json { render json: "OK", status: :ok }
	      else
	        format.json { render json: @friendship.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def add_user_app
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@app = App.where("package_name = ?", params[:package]).first

		if @app == nil
			# get app info from Play Store
			gps = GooglePlaySearch::Search.new(:category=>"apps")
			app_list = gps.search(params[:app])
			app = app_list.first
			# insert app
			@new_app = App.new()
			@new_app.name = params[:app]
			@new_app.package_name = params[:package]
			@new_app.icon_url = app.logo_url
			@new_app.link = app.url
			@new_app.category = app.category
			@new_app.description = app.short_description
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
	        format.json { render json: "OK", status: :ok }
	      else
	        format.json { render json: @user_app.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def delete_user_app
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@app = App.where("package_name = ?", params[:package]).first
		@user_app = UserApp.where("user_id = ? AND app_id = ?", @user.twitter_id, @app.id)
		
		respond_to do |format|
	      if UserApp.destroy(@user_app)
	        format.json { render json: "OK", status: :ok }
	      else
	        format.json { render json: @user_app.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def list_following
		@user = User.where("twitter_id = ?", params[:friend_id]).first
		@followings = Friend.where("friend_id = ?", params[:friend_id])

		puts @followings.length 

		@data = []
		@dataset = {}

		@followings.each do | f |
			# get user details here
			@user_details = User.where("twitter_id = ?", f.user_id).first
			# get tapped apps
			@user_apps_id = UserApp.where("user_id = ?", f.user_id)
			if !@user_apps_id
				@user_apps_count = @user_apps_id.length
			else
				@user_apps_count = 0
			end
			
			# get friends
			@friends = Friend.where(friend_id: f.user_id)
			if @friends != nil
				@friends_count = @friends.length
			else
				@friends_count = 0
			end
			
			# get followers
			@followers = Friend.where(user_id: f.user_id)
			if @followers != nil
				@followers_count = @followers.length
			else
				@followers_count = 0
			end

			@friend = Friend.where("friend_id = ? AND user_id = ?", params[:twitter_id], params[:friend_id])

			if @friend.blank?
				@is_followed = 0
			else
				@is_followed = 1
			end

			@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :description => @user_details.description, :profile_image_url => @user_details.profile_image_url, :is_verified => @user.is_verified, :count_apps => @user_apps_count, :count_friends => @friends_count, :count_followers => @followers_count, :is_followed => @is_followed}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def list_followers
		@followers = Friend.where("user_id = ?", params[:friend_id])

		@data = []
		@dataset = {}

		@followers.each do | f |
			# get user details here
			@user_details = User.where("twitter_id = ?", f.friend_id).first
			# get tapped apps
			@user_apps_id = UserApp.where("user_id = ?", f.friend_id)
			@user_apps_count = @user_apps_id.length
			# get friends
			@friends = Friend.where(friend_id: f.friend_id)
			@friends_count = @friends.length
			# get followers
			@followers = Friend.where(user_id: f.friend_id)
			@followers_count = @followers.length

			@friend = Friend.where("friend_id = ? AND user_id = ?", params[:twitter_id], params[:friend_id])

			if @friend.blank?
				@is_followed = 0
			else
				@is_followed = 1
			end

			@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :description => @user_details.description, :profile_image_url => @user_details.profile_image_url, :is_verified => @user_details.is_verified, :count_apps => @user_apps_count, :count_friends => @friends_count, :count_followers => @followers_count, :is_followed => @is_followed}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def feed
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@followings = Friend.where("friend_id = ?", params[:twitter_id])
		@friends = []
		@followings.each { |f| @friends << f.user_id} 

		@feed = UserApp.where(user_id: @friends).order(created_at: :desc).limit(100)

		@data = []
		@dataset = {}

		@feed.each do | f |
			@user_details = User.where("twitter_id = ?", f.user_id).first
			@app_details = App.find(f.app_id)
			@app_count = UserApp.where("app_id = ?", @app_details.id)
			@app_tapp_count = @app_count.length
			@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :profile_image_url => @user_details.profile_image_url, :is_verified => @user.is_verified, :app_id => @app_details.id, :app_name => @app_details.name, :app_icon => @app_details.icon_url, :app_link => @app_details.link, :app_category => @app_details.category, :app_description => @app_details.description, :app_tapp_count => @app_tapp_count}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def app_details
		@app = App.where("package_name = ?", params[:package]).first
		@app_count = UserApp.where("app_id = ?", @app.id)
		@app_tapp_count = @app_count.length
		@user_app = UserApp.where("user_id = ? AND app_id = ?", params[:twitter_id], @app.id)

		if !@user_app
			@tapped_by_user = 0
		else
			@tapped_by_user = 1
		end

		@data = []
		@dataset = {}

		@dataset = {:app_id => @app.id, :app_name => @app.name, :app_icon => @app.icon_url, :app_link => @app.link, :app_category => @app.category, :app_description => @app.description, :package_name => @app.package_name, :tapp_count => @app_tapp_count, :tapped_by_user => @tapped_by_user}
		@data << @dataset

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def app_users
		@app = App.where("package_name = ?", params[:package]).first
		@app_users = UserApp.where("app_id = ?", @app.id).order(created_at: :desc).limit(100)

		@data = []
		@dataset = {}

		@app_users.each do | f |
			@user_details = User.where("twitter_id = ?", f.user_id).first
			@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :profile_image_url => @user_details.profile_image_url, :is_verified => @user_details.is_verified}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def user_apps
		@user_apps = UserApp.where("user_id = ?", params[:twitter_id]).order(created_at: :desc)

		@data = []
		@dataset = {}

		@user_apps.each do | f |
			@app = App.where("id = ?", f.app_id).first
			@app_count = UserApp.where("app_id = ?", f.app_id)
			@app_tapp_count = @app_count.length
			@user_app = UserApp.where("user_id = ? AND app_id = ?", params[:twitter_id], @app.id)

			if @user_app.blank?
				@tapped_by_user = 0
			else
				@tapped_by_user = 1
			end

			@dataset = {:app_id => @app.id, :app_name => @app.name, :app_icon => @app.icon_url, :app_link => @app.link, :app_category => @app.category, :app_description => @app.description, :tapp_count => @app_tapp_count, :tapped_by_user => @tapped_by_user}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def friend_apps
		@user_apps = UserApp.where("user_id = ?", params[:friend_id]).order(created_at: :desc)

		@data = []
		@dataset = {}

		@user_apps.each do | f |
			@app = App.where("id = ?", f.app_id).first
			@app_count = UserApp.where("app_id = ?", f.app_id)
			@app_tapp_count = @app_count.length
			@user_app = UserApp.where("user_id = ? AND app_id = ?", params[:twitter_id], @app.id)

			if @user_app.blank?
				@tapped_by_user = 0
			else
				@tapped_by_user = 1
			end

			@dataset = {:app_id => @app.id, :app_name => @app.name, :app_icon => @app.icon_url, :app_link => @app.link, :app_category => @app.category, :app_description => @app.description, :tapp_count => @app_tapp_count, :tapped_by_user => @tapped_by_user}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def user_details
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@followings = Friend.where("friend_id = ?", params[:twitter_id])
		@followers = Friend.where("user_id = ?", params[:twitter_id])
		@followings_count = @followings.length
		@followers_count = @followers.length

		@data = []
		@dataset = {}

		@dataset = {:twitter_id => @user.twitter_id, :name => @user.name, :screen_name => @user.screen_name, :profile_image_url => @user.profile_image_url, :is_verified => @user.is_verified, :description => @user.description,  :is_verified => @user.is_verified, :followings => @followings_count, :followers => @followers_count}
			
		@data << @dataset

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def app_details
		@user = User.where("twitter_id = ?", params[:friend_id]).first
		@followings = Friend.where("friend_id = ?", params[:friend_id])
		@followers = Friend.where("user_id = ?", params[:friend_id])
		@followings_count = @followings.length
		@followers_count = @followers.length

		@friend = Friend.where("friend_id = ? AND user_id = ?", params[:twitter_id], params[:friend_id])

		if @friend.blank?
			@is_followed = 0
		else
			@is_followed = 1
		end

		@data = []
		@dataset = {}

		@dataset = {:twitter_id => @user.twitter_id, :name => @user.name, :screen_name => @user.screen_name, :profile_image_url => @user.profile_image_url, :is_verified => @user.is_verified, :description => @user.description,  :is_verified => @user.is_verified, :followings => @followings_count, :followers => @followers_count, :is_followed => @is_followed}
			
		@data << @dataset

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def leaderboard
		# Leaderboard only shows users which are ranking the highest on Tapp (most tapped apps).
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@leaderboard = UserApp.select('user_id, count(app_id) cnt').group("user_id").order("cnt desc").limit(100)

		@data = []
		@dataset = {}

		@leaderboard.each do | f |

			puts "xxxxx"
			puts f.user_id

			@user_details = User.where("twitter_id = ?", f.user_id).first
			@friend = Friend.where("friend_id = ? AND user_id = ?", @user.twitter_id, f.user_id)
			# get followers
			@followers = Friend.where(user_id: f.user_id)
			@followers_count = @followers.length

			if @friend.blank?
				@is_followed = 0
			else
				@is_followed = 1
			end

			@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :profile_image_url => @user_details.profile_image_url, :description => @user_details.description,  :is_verified => @user_details.is_verified, :followers => @followers_count, :apps => f.cnt, :is_followed => @is_followed}
		
		  	@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def search_user
		@result = User.where("name LIKE ? OR screen_name like ?", "%#{params[:q]}%", "%#{params[:q]}%").limit(100)

		@data = []
		@dataset = {}

		@result.each do | f |
			@user_details = User.where("twitter_id = ?", f.twitter_id).first
			@friend = Friend.where("friend_id = ? AND user_id = ?", params[:twitter_id], f.twitter_id)
			# get followers
			@followers = Friend.where(user_id: f.twitter_id)
			@followers_count = @followers.length
			# get apps
			@app_count = UserApp.where("user_id = ?", f.twitter_id)
			@app_tapp_count = @app_count.length

			if @friend == nil
				@is_followed = 0
			else
				@is_followed = 1
			end

			@dataset = {:twitter_id => f.twitter_id, :name => f.name, :screen_name => f.screen_name, :profile_image_url => f.profile_image_url, :description => f.description,  :is_verified => f.is_verified, :followers => @followers_count, :apps => @app_tapp_count, :is_followed => @is_followed}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def search_app
		@result = App.where("name LIKE ? OR package_name like ?", "%#{params[:q]}%", "%#{params[:q]}%").limit(100)

		@data = []
		@dataset = {}

		@result.each do | f |
			@app_count = UserApp.where("app_id = ?", f.id)
			@app_tapp_count = @app_count.length
			@user_app = UserApp.where("app_id = ? AND user_id = ?", f.id, params[:twitter_id]).first

			if @user_app == nil
				@is_tapped = 0
			else
				@is_tapped = 1
			end

			@dataset = {:app_id => f.id, :app_name => f.name, :app_icon => f.icon_url, :app_link => f.link, :app_category => f.category, :app_description => f.description, :tapp_count => @app_tapp_count, :tapped_by_user => @is_tapped}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def popular_apps_overall
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@popular = UserApp.select('app_id, count(user_id) cnt').group("app_id").order("cnt desc").limit(100)

		@data = []
		@dataset = {}

		@popular.each do | f |
			@app = App.find(f.app_id)
			@user_app = UserApp.where("app_id = ? AND user_id = ?", @app.id, params[:twitter_id]).first

			if @user_app == nil
				@is_tapped = 0
			else
				@is_tapped = 1
			end

			@dataset = {:app_id => @app.id, :app_name => @app.name, :app_icon => @app.icon_url, :app_link => @app.link, :app_category => @app.category, :app_description => @app.description, :package_name => @app.package_name, :tapp_count => f.cnt, :tapped_by_user => @is_tapped}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def popular_apps_followers
		@user = User.where("twitter_id = ?", params[:twitter_id]).first
		@followers = Friend.where("user_id = ?", params[:twitter_id])

		@friends = []
		@followers.each { |f| @friends << f.friend_id} 

		@popular = UserApp.select('app_id, count(user_id) cnt').where(user_id: @friends).group("app_id").order("cnt desc").limit(100)

		@data = []
		@dataset = {}

		@popular.each do | f |
			@app = App.find(f.app_id)
			@user_app = UserApp.where("app_id = ? AND user_id = ?", @app.id, params[:twitter_id]).first

			if @user_app == nil
				@is_tapped = 0
			else
				@is_tapped = 1
			end

			@dataset = {:app_id => @app.id, :app_name => @app.name, :app_icon => @app.icon_url, :app_link => @app.link, :app_category => @app.category, :app_description => @app.description, :package_name => @app.package_name, :tapp_count => f.cnt, :tapped_by_user => @is_tapped}
			@data << @dataset
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
	end

	def delete_all_friends
		@friend = Friend.where("friend_id = ?", params[:twitter_id])

		respond_to do |format|
	      if Friend.destroy(@friend)
	        format.json { render json: "OK", status: :ok }
	      else
	        format.json { render json: @friend.errors, status: :unprocessable_entity }
	      end
	    end
	end

	def find_friends
		@twitter_friends = params[:twitter_ids].split(",")

		puts @twitter_friends

		@data = []
		@dataset = {}

		@twitter_friends.each do | f |
			@user_details = User.where("twitter_id = ?", f).first
			if @user_details != nil
				@friend = Friend.where("friend_id = ? AND user_id = ?", params[:twitter_id], f)
				# get followers
				@followers = Friend.where(user_id: f)
				if @followers == nil
					@followers_count = 0
				else
					@followers_count = @followers.length
				end
				
				# get apps
				@app_count = UserApp.where("user_id = ?", f)
				if @app_count == nil
					@app_tapp_count = 0
				else
					@app_tapp_count = @app_count.length
				end	

				if @friend.blank?
					@is_followed = 0
				else
					@is_followed = 1
				end

				@dataset = {:twitter_id => @user_details.twitter_id, :name => @user_details.name, :screen_name => @user_details.screen_name, :profile_image_url => @user_details.profile_image_url, :description => @user_details.description,  :is_verified => @user_details.is_verified, :followers => @followers_count, :apps => @app_tapp_count, :is_followed => @is_followed}
				@data << @dataset
			end
			
		end

		respond_to do |format|
	      if @data.length > 0
	        format.json { render json: @data, status: :ok }
	      else
	        format.json { render json: @data, status: :unprocessable_entity }
	      end
	    end
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
		params.require(:friend).permit(:user_id, :friend_id, :friendship_dt)
	end

	def app_params
		params.require(:app).permit(:name, :package_name, :icon_url, :link, :category, :description)
	end

	def user_apps_params
		params.require(:user_apps).permit(:user_id, :app_id)
	end

end
