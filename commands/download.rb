module Download
  extend Discordrb::Commands::CommandContainer

  command(:download) do |event|
    tardis_site = RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/')
    tardis_parsed = Nokogiri::HTML.parse(tardis_site.body)
    tardis_build = doc.at('#breadcrumbs > li:nth-child(5) > a').text

    tardis_chunk_site = RestClient.get('http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISChunkGenerator/lastSuccessfulBuild/')
    tardis_chunk_parsed = Nokogiri::HTML.parse(tardis_chunk_site.body)
    tardis_chunk_build = doc.at('#breadcrumbs > li:nth-child(7) > a').text
    event.channel.send_embed do |embed|
      embed.title "Handles Help"
      embed.description = "Make sure your TARDIS is up to date! If your server version is 1.15.2 or greater, it's ideal to make sure your TARDIS is up to date as well. Use the links below to download the latest build of BOTH TARDIS and TARDISChunkGenerator"
      embed.add_field(name: 'TARDIS', value: "[Build #{tardis_build}](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild)", inline: true)
      embed.add_field(name: 'TARDISChunkGenerator', value: "[Build #{tardis_chunk_build}](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISChunkGenerator/lastSuccessfulBuild)", inline: true)
    end
  end
end
