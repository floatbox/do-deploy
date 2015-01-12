require 'tweetstream'

namespace :ts do

  desc "Run Twitter Scraper"
  task track: :environment do

    twitter_app_auth = YAML::load_file('config/twitter_app.yml')
    TweetStream.configure do |config|
      config.consumer_key       = twitter_app_auth['consumer_key']
      config.consumer_secret    = twitter_app_auth['consumer_secret']
      config.oauth_token        = twitter_app_auth['oauth_token']
      config.oauth_token_secret = twitter_app_auth['oauth_token_secret']
      config.auth_method        = :oauth
    end

    TweetStream::Client.new.track('@navalny') do |status|
      ActiveRecord::Base.connection.reconnect!
      Post.create(title: status.user.screen_name, description: status.text)
      puts "[#{status.user.screen_name}] #{status.text}"
    end

  end

end
