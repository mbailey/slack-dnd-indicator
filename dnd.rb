#!/usr/bin/env ruby

require 'date'
require 'colorize'
require 'slack-ruby-client'

# Legacy tokens are an old method of generating tokens for testing and development.
# Slack do not recommend their use.
#
# TODO: Work out whether this script can use OAuth flow with [Slack Apps](https://api.slack.com/slack-apps)
#
# You can easily get one [here](https://api.slack.com/custom-integrations/legacy-tokens)
#
# And then make it available to this script through an environment variable:
#
# ```
# $ export SLACK_API_TOKEN=xoxb-1111111111-222222222222-333333333333333333333333
# ```

SNOOZED  ='snoozed  '.red
AVAILABLE='available'.green

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

# Do an initial check of Snooze State

client = Slack::Web::Client.new
dnd_info = client.dnd_info

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

# We'll output the status after we output the msg about connecting below
# We're being tricky with updating the songle status line


## Open up a WebSocket connection and watch for updates to Snooze State

client = Slack::RealTime::Client.new

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
