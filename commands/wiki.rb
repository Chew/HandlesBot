module Wiki
  extend Discordrb::Commands::CommandContainer

  command(:wiki, min_args: 1) do |event, *search|
    search = search.join(' ')
    m = event.channel.send_embed do |embed|
      embed.title = 'Handles Wiki Search'
      embed.description = 'Searching the wiki...'
    end

    wiki_site = RestClient.get('https://eccentricdevotion.github.io/TARDIS/site-map.html')
    wiki_parsed = Nokogiri::HTML.parse(wiki_site.body)

    length = wiki_parsed.search("a").length

    results = []

    wiki_parsed.search('a')[4..length - 3].each do |item|
      if item.text.downcase.include?(search.downcase)
        results.push "[#{item.text}](https://eccentricdevotion.github.io/TARDIS/#{item.attributes['href'].value})"
      end
    end

    results.push "No results found" if results.empty?

    embed = Discordrb::Webhooks::Embed.new(
      title: 'Handles Wiki Search',
      description: "Results:\n" + results.join("\n")
    )

    m.edit('', embed)
  end
end
