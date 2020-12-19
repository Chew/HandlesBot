require 'discordrb'
require 'yaml'
require 'json'
require 'rest-client'
require 'nokogiri'
require 'rufus-scheduler'

SCHEDULER = Rufus::Scheduler.new

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

def check_for_build
  puts "Checking for new builds..."
  begin
    begin
      latest_in_server = BOT.channel(696383624563392552).history(1)[0].embeds[0].title.split('#').last.split(' ').first.to_i
    rescue StandardError
      latest_in_server = 300000
    end

    tardis_site = JSON.parse(RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/api/json/'))
    latest_on_jenkins = tardis_site['number'].to_i

    if latest_on_jenkins != latest_in_server
      changes = tardis_site['changeSet']['items'].map { |e| e['comment'].chomp }
      puts "New build found!"

      m = BOT.channel(696383624563392552).send_embed do |embed|
        embed.title = "TARDIS Build \##{latest_on_jenkins} is now available!"
        embed.description = "[Download it here!](#{tardis_site['url']}/)\n\nChanges:\n* #{changes.join("\n* ")}"
      end
      messageid = m.id
      puts "Message ID: #{m.id}"
      begin
        RestClient.post("https://discord.com/api/v6/channels/696383624563392552/messages/#{messageid}/crosspost", nil, Authorization: BOT.token)
      rescue RestClient::Unauthorized => e
        puts "You done hecked up. Error: #{e.response.body}"
      end
    else
      puts "Up to date!"
    end
  rescue StandardError => e
    puts "You failed. You really failed. At getting the latest build. Try again!"
    puts e
  end
end

loadpls
check_for_build

BOT.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded sucessfully!'
end

puts 'Done loading plugins! Finalizing start-up'

puts 'Bot is ready!'
BOT.run
