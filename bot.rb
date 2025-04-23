require 'discordrb'
require 'yaml'
require 'json'
require 'rest-client'
require 'rufus-scheduler'

SCHEDULER = Rufus::Scheduler.new

STARTTIME = Time.now

CONFIG = YAML.load_file('config.yaml')

BOT = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: ['handles', 'hey handles', 'handles,', 'hey handles,'],
                                          spaces_allowed: true,
                                          help_command: false,
                                          ignore_bots: true

def loadpls
  BOT.clear!
  Dir["#{File.dirname(__FILE__)}/commands/*.rb"].sort.each do |wow|
    load wow
    require wow
    bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
    command = bob[0][7..bob[0].length]
    command.delete!("\n")
    command = Object.const_get(command)
    BOT.include! command
    puts "Command #{command} successfully loaded!"
  end
end

SCHEDULER.every('2m') do
  check_for_build
end

def last_build(update = nil)
  if update
    # update the last build number
    last_file = YAML.load_file('last_build.yml')
    last_file['build'] = update
    File.open('last_build.yml', 'w') { |f| f.write(last_file.to_yaml) }
  else
    # return the last build number
    last_file = YAML.load_file('last_build.yml')
    last_file['build']
  end
end

def check_for_build
  puts "Checking for new builds..."
  begin
    begin
      latest_in_server = last_build
    rescue StandardError
      return
    end

    tardis_site = JSON.parse(RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/api/json/'))
    latest_on_jenkins = tardis_site['number'].to_i

    if latest_on_jenkins != latest_in_server
      changes = tardis_site['changeSet']['items']
                  .map { |e| "[#{e['commitId'][0..7]}](https://github.com/eccentricdevotion/TARDIS/commit/#{e['commitId']}) - #{e['msg'].chomp}" }
                  .map { |e| "* #{e}" }
      build_time = tardis_site['timestamp'] / 1000
      puts "New build found!"

      payload = {
        "components": [
          {
            "type": 17,
            "components": [
              {
                "type": 10,
                "content": "# TARDIS Plugin Update",
              },
              {
                "type": 10,
                "content": "Build #{latest_on_jenkins} is now available!\nReleased <t:#{build_time}:R> (<t:#{build_time}:f>)",
              },
              {
                "type": 14,
                "divider": true
              },
              {
                "type": 10,
                "content": changes.join("\n")
              },
            ]
          },
          {
            "type": 1,
            "components": [
              {
                "type": 2,
                "label": "View on Jenkins",
                "style": 5,
                "url": tardis_site['url']
              }
            ]
          }
        ],
        "flags": 1 << 15,
      }

      puts "Sending..."
      message = RestClient.post("https://discord.com/api/v10/channels/696383624563392552/messages", payload.to_json, Authorization: BOT.token, 'Content-Type': :json)
      #puts "Message sent: #{message}"
      m_id = JSON.parse(message)['id']
      puts "Message ID: #{m_id}"
      begin
        RestClient.post("https://discord.com/api/v6/channels/696383624563392552/messages/#{m_id}/crosspost", nil, Authorization: BOT.token)
      rescue RestClient::Unauthorized => e
        puts "Not authorized to crosspost: #{e}"
        return
      end

      last_build(latest_on_jenkins)
    else
      puts "Up to date!"
    end
  rescue RestClient::BadRequest => e
    puts "Bad request: #{e}"
    puts e.response.body
  rescue StandardError
    puts "Error checking for build: #{$!}"
    return
  end
end

loadpls
check_for_build

BOT.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded successfully!'
end

puts 'Done loading plugins! Finalizing start-up'

puts 'Bot is ready!'
BOT.run
