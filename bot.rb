require 'discordrb'
require 'yaml'
require 'rest-client'
require 'nokogiri'
require 'rufus-scheduler'

Scheduler = Rufus::Scheduler.new

CONFIG = YAML.load_file('config.yaml')

Bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: ['handles', 'hey handles', 'handles,', 'hey handles,'],
                                          spaces_allowed: true,
                                          help_command: false

def loadpls
  Bot.clear!
  Dir["#{File.dirname(__FILE__)}/commands/*.rb"].sort.each do |wow|
    load wow
    require wow
    bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
    command = bob[0][7..bob[0].length]
    command.delete!("\n")
    command = Object.const_get(command)
    Bot.include! command
    puts "Command #{command} successfully loaded!"
  end
end

Scheduler.every('5m') do
  check_for_build
end

def check_for_build
  puts "Checking for new builds..."
  begin
    begin
      latest_in_server = Bot.channel(696383624563392552).history(1)[0].embeds[0].title.split('#').last.split(' ').first.to_i
    rescue StandardError
      latest_in_server = 0
    end

    tardis_site = RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/')
    tardis_parsed = Nokogiri::HTML.parse(tardis_site.body)
    latest_on_jenkins = tardis_parsed.at('#breadcrumbs > li:nth-child(5) > a').text.gsub('#', '').to_i

    if latest_on_jenkins != latest_in_server
      changes = tardis_parsed.at('#main-panel > table').children[1].text.split('(details / githubweb)').map{|e| e.gsub('  ', '')}.delete_if{|e| !e.include?("commit:")}.map{|e| e.gsub("\nChanges\n", '')}.map{|e| e.split(' (commit:').first}

      Bot.channel(696383624563392552).send_embed do |embed|
        embed.title = "TARDIS Build \##{latest_on_jenkins} is now available!"
        embed.description = "[Download it here!](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/)\nChanges:\n#{changes.join("\n")}"
      end
      puts "New build found!"
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

Bot.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded sucessfully!'
end

puts 'Done loading plugins! Finalizing start-up'

puts 'Bot is ready!'
Bot.run
