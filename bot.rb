require 'discordrb'
require 'yaml'
require 'rest-client'

CONFIG = YAML.load_file('config.yaml')

Bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: ['handles', 'hey handles'],
                                          spaces_allowed: true,
                                          help_command: false

def loadpls
  Bot.clear!
  Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].sort.each do |wow|
    load wow
    require wow
    bob = File.readlines(wow) { |line| line.split.map(&:to_s).join }
    command = bob[0][7..bob[0].length]
    command.delete!("\n")
    command = Object.const_get(command)
    Bot.include! command
    puts "Plugin #{command} successfully loaded!"
  end
end

loadpls

Bot.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded sucessfully!'
end

puts 'Done loading plugins! Finalizing start-up'

puts 'Bot is ready!'
Bot.run
