#!/usr/bin/env ruby

require 'colorize'
require 'date'
require 'json'
require 'launchy'
require 'net/http'
require 'rack'
require 'slack-ruby-client'

CLIENT_ID     = '482089069124.482646530357'
CLIENT_SECRET = '2e1ac863fad867bc3c8beb7b2bcbbfda'
REDIRECT_URI  = 'http://localhost:9000/'   # /get-code/

CODE = ENV['CODE']

unless CODE 

  class ListenForCode
    def call(env)
      params = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      pp params
      ENV['CODE'] = params['code']
      # ENV['CODE'] = 'xoxp-2265956257-2282801951-470888371793-5bf63d15b0da6c9c1bc090f899b29a44'
      exec $0, ENV['CODE'] 
      return [200, {}, [ENV['CODE']]]
    end
  end

  puts "We're going to redirect you to login"
  
  Launchy.open("https://slack.com/oauth/authorize?client_id=#{CLIENT_ID}&scope=dnd:read&redirect_uri=#{REDIRECT_URI}")

  Rack::Handler::WEBrick.run(
    ListenForCode.new,
    :Port => 9000
  )
end


puts "Second time"

# Get token

def get_token(code)
  url = "https://slack.com/api/oauth.access?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&code=#{code}&redirect_uri=#{REDIRECT_URI}"
#   url = "https://slack.com/api/oauth.access?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&code=#{code}"
  puts url
  uri = URI(url)
  response = Net::HTTP.get(uri)
  f = JSON.parse(response)
  pp f
  return f["access_token"]
end

foo = get_token CODE
puts foo
ENV['SLACK_API_TOKEN'] = foo


# ---
#
SNOOZED  ='snoozed  '.red
AVAILABLE='available'.green

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

# Do an initial check of Snooze State

client = Slack::Web::Client.new
dnd_info = client.dnd_info user: 'UE5FC3U4Q'

# {"ok"=>true,
#  "dnd_enabled"=>true,
#  "next_dnd_start_ts"=>1541574000,
#  "next_dnd_end_ts"=>1541631600,
#  "snooze_enabled"=>false}

def status(dnd_info)
  pp dnd_info if ENV['DEBUG']
  if dnd_info[:snooze_enabled]
    `/usr/local/bin/blink1-tool --red`
    SNOOZED
  else
    `/usr/local/bin/blink1-tool --green`
    AVAILABLE
  end
end

pp dnd_info if ENV['DEBUG']

print status(dnd_info)
exit

# We'll output the status after we output the msg about connecting below
# We're being tricky with updating the songle status line


## Open up a WebSocket connection and watch for updates to Snooze State

client = Slack::RealTime::Client.new user: 'UE5FC3U4Q'

client.on :hello do
  puts "Connected as '#{client.self.name}' to '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  print status(dnd_info)
end

client.on :dnd_updated do |dnd_info|
  print "\r#{status(dnd_info.dnd_status)}"
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
