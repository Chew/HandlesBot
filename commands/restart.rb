module Restart
  extend Discordrb::Commands::CommandContainer

  command(:update) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "Imma keep it real with u chief! You can't update the bot."
      break
    end
    m = event.respond 'Updating...'
    changes = `git pull`
    m.edit('', Discordrb::Webhooks::Embed.new(
                 title: '**Updated Successfully**',

                 description: changes,
                 color: 0x7ED321
               ))
  end

  command(:updates) do |event|
    `git fetch` if event.user.id == CONFIG['owner_id']
    response = `git rev-list origin/master | wc -l`.to_i
    commits = `git rev-list master | wc -l`.to_i
    if commits.zero?
      event.respond 'Git machine broke! Call the department!'
      break
    end
    if event.user.id == CONFIG['owner_id']
      event.channel.send_embed do |e|
        e.title = "You are running Handles Bot commit #{commits}"
        if response == commits
          e.description = 'You are running the latest commit.'
          e.color = '00FF00'
        elsif response < commits
          e.description = "You are running an un-pushed commit! Are you a developer? (Most Recent: #{response})\n**Here are up to 5 most recent commits.**\n#{`git log origin/master..master --pretty=format:\"[%h](http://github.com/Chew/HandlesBot/commit/%H) - %s\" -5`}"
          e.color = 'FFFF00'
        else
          e.description = "You are #{response - commits} commit(s) behind! Run `handles update` to update.\n**Here are up to 5 most recent commits.**\n#{`git log master..origin/master --pretty=format:\"[%h](http://github.com/Chew/HandlesBot/commit/%H) - %s\" -5`}"
          e.color = 'FF0000'
        end
      end
    end
  end

  command(:shoo) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond 'Why are you trying to kill Handles? What has he ever done to you? Leave him alone!'
      break
    end
    event.respond "I am shutting down, it's been a long run folks!"
    exit
  end
end
