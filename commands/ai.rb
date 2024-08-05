module Ai
  extend Discordrb::Commands::CommandContainer

  # @param event [CommandEvent] The event of the message that contained the command.
  # @type event [CommandEvent]
  command(:ai, min_args: 1) do |event, *search|
    # get user roles
    roles = event.user.roles.map(&:name)

    unless roles.include?('Helper') || roles.include?('Notable')
      event.respond 'You do not have permission to use this command.'
      next
    end

    search = search.join(' ')
    m = event.channel.send_embed do |embed|
      embed.title = 'Handles Wiki Search'
      embed.description = 'Searching the wiki via AI...'
    end

    puts "search: #{search}"

    response = "pending..."

    begin
      thread = JSON.parse(RestClient.post("https://api.openai.com/v1/threads/runs", {
        assistant_id: "asst_yUiLfxXd3UG1NA97mT3pRvAI",
        thread: {
          messages: [
            {
              role: "user",
              content: search
            }
          ]
        },
        # forces the AI to search the wiki
        tool_choice: {
          type: "file_search"
        }
      }.to_json, { Authorization: "Bearer #{CONFIG['openai']}", 'OpenAI-Beta': 'assistants=v2', 'Content-Type': 'application/json' } ))

      thread_id = thread['thread_id']
      run_id = thread['id']

      puts "thread_id: #{thread_id}, run_id: #{run_id}"

      completed = false
      until completed
        # sleep for 1 second
        sleep 1

        puts "Checking run status"

        run_status = JSON.parse(RestClient.get("https://api.openai.com/v1/threads/#{thread_id}/runs/#{run_id}",
                                               { Authorization: "Bearer #{CONFIG['openai']}", 'OpenAI-Beta': 'assistants=v2', 'Content-Type': :json }))

        completed = run_status['status'] == 'completed'

        puts "Run status: #{run_status['status']}"
      end

      messages = JSON.parse(RestClient.get("https://api.openai.com/v1/threads/#{thread_id}/messages",
                                           { Authorization: "Bearer #{CONFIG['openai']}", 'OpenAI-Beta': 'assistants=v2', 'Content-Type': :json }))

      response = messages['data'][0]['content'][0]['text']['value']

      puts "Found response: #{response}"
    rescue RestClient::BadRequest => e
      response = "An error occurred while searching the wiki. Please try again later."
      puts "Error: #{e}, #{e.response.body}"
    end

    embed = Discordrb::Webhooks::Embed.new(
      title: 'Handles Wiki Search',
      description: response,
      footer: Discordrb::Webhooks::EmbedFooter.new(
        text: 'Powered by OpenAI',
        icon_url: 'https://avatars.githubusercontent.com/u/14957082'
      )
    )

    m.edit('', embed)
  end
end
