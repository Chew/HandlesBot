module About
  extend Discordrb::Commands::CommandContainer

  command(:help, aliases: [:about]) do |event|
    event.channel.send_embed do |embed|
      embed.title = 'Hello, I am Handles'
      embed.colour = '36399A'
      embed.description = 'My purpose is to serve this server! (I suppose IM the server then)'

      embed.add_field(name: 'Commands', value: 'My command list can be found with `handles commands`', inline: true)
    end
  end

  command(:commands) do |event|
    event.channel.send_embed do |embed|
      embed.title = 'My Commands'
      embed.colour = '36399A'

      embed.add_field(name: 'Help Commands', value: [
        '`handles download` - Find download links to the TARDIS plugin',
      ].join("\n"), inline: false)
    end
  end

  command(:ping, min_args: 0, max_args: 1) do |event, noedit|
    if noedit == 'noedit'
      event.respond "Pong! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
    else
      m = event.respond('Pinging...')
      m.edit "Pong!! Time taken: #{((Time.now - event.timestamp) * 1000).to_i} milliseconds."
    end
  end

  command(:info, aliases: [:bot]) do |event|
    t = Time.now - Starttime
    mm, ss = t.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    days = format("%d days\n", dd) if dd != 0
    hours = format("%d hours\n", hh) if hh != 0
    mins = format("%d minutes\n", mm) if mm != 0
    secs = format('%d seconds', ss) if ss != 0

    commits = `git rev-list master | wc -l`.to_i

    botversion = if commits.zero?
                   ''
                 else
                   "Commit: #{commits}"
                 end

      event.channel.send_embed do |e|
        e.title = 'Handles Stats!'

        e.add_field(name: 'Author', value: event.bot.user(CONFIG['owner_id']).distinct, inline: true)
        e.add_field(name: 'Code', value: '[Code on GitHub](https://github.com/Chew/HandlesBot)', inline: true)
        e.add_field(name: 'Bot Version', value: botversion, inline: true) unless botversion == ''
        e.add_field(name: 'Library', value: 'discordrb 3.3.0', inline: true)
        e.add_field(name: 'Uptime', value: "#{days}#{hours}#{mins}#{secs}", inline: true)
        e.color = '36399A'
      end
  end

  command(:lib) do |event|
    gems = `gem list`.split("\n")
    libs = ['discordrb', 'rest-client', 'json', 'nokogiri']
    versions = []
    libs.each do |name|
      version = gems[gems.index { |s| s.include?(name) }].split(' ')[1]
      versions[versions.length] = version.delete('(').delete(',').delete(')')
    end
    begin
      event.channel.send_embed do |e|
        e.title = 'HandlesBot - Open Source Libraries'

        (0..libs.length - 1).each do |i|
          url = "http://rubygems.org/gems/#{libs[i]}/versions/#{versions[i]}"
          e.add_field(name: libs[i], value: "[#{versions[i]}](#{url})", inline: true)
        end
        e.color = '36399A'
      end
    rescue Discordrb::Errors::NoPermission
      event.respond 'Hey! It\'s me, money-flippin\' Matt Richards! I need some memes, dreams, and the ability to embed links! You gotta grant me these permissions!'
    end
  end
end
