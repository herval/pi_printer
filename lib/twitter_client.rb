require 'twitter'

class TwitterClient

  def initialize(configuration_options)
    @search_term = configuration_options[:search_term]
    @refresh_seconds = configuration_options[:refresh_seconds].to_i
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = configuration_options[:consumer_key]
      config.consumer_secret = configuration_options[:consumer_secret]
    end
  end

  def listen
    latest_id = 0
    while true
      begin
        @client.search(@search_term, :result_type => "recent").take(1).collect do |tweet|
          if latest_id < tweet.id
            latest_id = tweet.id
            yield Tweet.new(tweet)
          end
        end
        sleep(@refresh_seconds)
      rescue => e
        puts "OH NOES! Can't connect to Twitter: #{e.message}"
        sleep(10)
      end
    end
  end

end


class Tweet

  def initialize(twitter_tweet)
    @original_tweet = twitter_tweet
  end

  def to_s
    "#{@original_tweet.user.screen_name}: #{@original_tweet.text} - #{@original_tweet.created_at}"
  end

end
