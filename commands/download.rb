module Download
  extend Discordrb::Commands::CommandContainer

  command(:download) do |event|
    m = event.channel.send_embed do |embed|
      embed.title = "Handles Help"
      embed.description = "Make sure your TARDIS is up to date! If your server version is 1.16.4 or greater, it's ideal to make sure your TARDIS is up to date as well. Use the links below to download the latest build of BOTH TARDIS and TARDISChunkGenerator"
      embed.add_field(name: 'TARDIS', value: "[Build (Loading...)](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild)", inline: true)
    end

    tardis_build = JSON.parse(RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/api/json'))['number'].to_i

    embed = Discordrb::Webhooks::Embed.new(
      title: "Handles Help",
      description: "Make sure your TARDIS is up to date! If your server version is 1.16.4 or greater, it's ideal to make sure your TARDIS is up to date as well. Use the links below to download the latest build of BOTH TARDIS and TARDISChunkGenerator",
      fields: [
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDIS',
          value: "[Build #{tardis_build}](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild)",
          inline: true
        )
      ]
    )

    m.edit('', embed)
  end
end
