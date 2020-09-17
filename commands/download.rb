module Download
  extend Discordrb::Commands::CommandContainer

  command(:download) do |event|
    m = event.channel.send_embed do |embed|
      embed.title = "Handles Help"
      embed.description = "Make sure your TARDIS is up to date! If your server version is 1.16.3 or greater, it's ideal to make sure your TARDIS is up to date as well. Use the links below to download the latest build of BOTH TARDIS and TARDISChunkGenerator"
      embed.add_field(name: 'TARDIS', value: "[Build (Loading...)](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild)", inline: true)
      embed.add_field(name: 'TARDISChunkGenerator', value: "[Build (Loading...)](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISChunkGenerator/lastSuccessfulBuild)", inline: true)
    end

    tardis_build = JSON.parse(RestClient.get('http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild/api/json'))['number'].to_i
    tardis_chunk_build = JSON.parse(RestClient.get('http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISChunkGenerator/lastSuccessfulBuild/api/json'))['number'].to_i

    embed = Discordrb::Webhooks::Embed.new(
      title: "Handles Help",
      description: "Make sure your TARDIS is up to date! If your server version is 1.16.3 or greater, it's ideal to make sure your TARDIS is up to date as well. Use the links below to download the latest build of BOTH TARDIS and TARDISChunkGenerator",
      fields: [
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDIS',
          value: "[Build #{tardis_build}](http://tardisjenkins.duckdns.org:8080/job/TARDIS/lastSuccessfulBuild)",
          inline: true
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDISChunkGenerator',
          value: "[Build #{tardis_chunk_build}](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISChunkGenerator/lastSuccessfulBuild)",
          inline: true
        )
      ]
    )

    m.edit('', embed)
  end

  command(:addons) do |event|
    m = event.channel.send_embed do |embed|
      embed.title = "Handles Help"
      embed.description = "TARDIS Has Plenty of Optional Addons! Check them out below. There are also resource packs, check those out with `handles, resourcepacks`"
      embed.add_field(name: 'TARDISSonicBlaster', value: "[Download Build (Loading...)](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISSonicBlaster/)\nThe Squareness Gun", inline: true)
      embed.add_field(name: 'TARDISVortexManipulator', value: "[Download Build (Loading...)](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISVortexManipulator/)\nVortex manipulator. Cheap and nasty time travel. Very bad for you. I'm trying to give it up.", inline: true)
      embed.add_field(name: 'TARDISWeepingAngels', value: "[Download Build (Loading...)](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISWeepingAngels/)\nThis plugin tranforms skeletons into terrifying Weeping Angels (as seen on Doctor Who). It also has Cybermen, Daleks, Empty Children, Ood, Silurians, Sontarans, Strax, Vashta Nerada and Zygons.", inline: false)
    end

    addons_site = RestClient.get('http://tardisjenkins.duckdns.org:8080/view/TARDIS/')
    addons_parsed = Nokogiri::HTML.parse(addons_site.body)

    sbv = addons_parsed.at('#job_TARDISSonicBlaster > td:nth-child(4) > a').text
    vmv = addons_parsed.at('#job_TARDISVortexManipulator > td:nth-child(4) > a').text
    wav = addons_parsed.at('#job_TARDISWeepingAngels > td:nth-child(4) > a').text

    embed = Discordrb::Webhooks::Embed.new(
      title: "Handles Help",
      description: "TARDIS Has Plenty of Optional Addons! Check them out below. There are also resource packs, check those out with `handles, resourcepacks`",
      fields: [
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDISSonicBlaster',
          value: "[Download Build #{sbv}](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISSonicBlaster/)\nThe Squareness Gun",
          inline: true
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDISVortexManipulator',
          value: "[Download Build #{vmv}](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISVortexManipulator/)\nVortex manipulator. Cheap and nasty time travel. Very bad for you. I'm trying to give it up.",
          inline: true
        ),
        Discordrb::Webhooks::EmbedField.new(
          name: 'TARDISWeepingAngels',
          value: "[Download Build #{wav}](http://tardisjenkins.duckdns.org:8080/view/TARDIS/job/TARDISWeepingAngels/)\nThis plugin tranforms skeletons into terrifying Weeping Angels (as seen on Doctor Who). It also has Cybermen, Daleks, Empty Children, Ood, Silurians, Sontarans, Strax, Vashta Nerada and Zygons.",
          inline: false
        )
      ]
    )

    m.edit('', embed)
  end
end
