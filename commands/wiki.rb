module Wiki
  extend Discordrb::Commands::CommandContainer

  command(:wiki, min_args: 1) do |event, *search|
    search = search.join(' ')
    m = event.channel.send_embed do |embed|
      embed.title = 'Handles Wiki Search'
      embed.description = 'Searching the wiki...'
    end

    wiki_site = RestClient.get('https://tardis.pages.dev/search-doc.json')
    wiki_parsed = JSON.parse wiki_site

    length = wiki_parsed.length

    results = []

    wiki_parsed['searchDocs'].each do |item|
      if item['title'].downcase.include?(search.downcase)
        if item['type'] == 0
          results.push "[#{item['title']}](https://tardis.pages.dev#{item['url']})"
        elsif item['type'] == 1
          results.push "[#{item['pageTitle']} > #{item['title']}](https://tardis.pages.dev#{item['url']})"
        end
      end
    end

    results.push "No results found" if results.empty?

    results = results.sort

    embed = Discordrb::Webhooks::Embed.new(
      title: 'Handles Wiki Search',
      description: "Results:\n" + results.join("\n")
    )

    m.edit('', embed)
  end
end
