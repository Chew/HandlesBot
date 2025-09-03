require 'discordrb'
require 'yaml'
require 'json'
require 'rest-client'

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

loadpls

BOT.command(:reload) do |event|
  break unless event.user.id == CONFIG['owner_id']

  loadpls
  event.respond 'Reloaded successfully!'
end

puts 'Done loading plugins! Finalizing start-up'

puts 'Bot is ready!'
BOT.run
