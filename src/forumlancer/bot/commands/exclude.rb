# frozen_string_literal: true

require 'discordrb'

require_relative '../../forum/objects'

# Implements the bot's exclusion-related commands.
module Exclude
  extend Discordrb::Commands::CommandContainer

  command :exclude, { description: 'Exclude a forum account from causing notifications' } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      excluded = Storage::SERVERS[event.server.id][:excluded]

      break event.channel.send_message('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url)

      break event.channel.send_message("_Already excluded: __#{user.name}__!_") if excluded.include? profile_url

      excluded.add profile_url
      event.channel.send_message("_OK, excluding posts by __#{user.name}__._")
    end
  end

  command :include,
          { description: 'Allow posts from this account to cause notifications', aliases: [:unexclude] } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      excluded = Storage::SERVERS[event.server.id][:excluded]

      break event.channel.send_message('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url)

      break event.channel.send_message("_Hadn't excluded: __#{user.name}__!_") unless excluded.include? profile_url

      excluded.delete profile_url
      event.channel.send_message("_OK, no longer excluding posts by __#{user.name}__._")
    end
  end

  command :excluded, { description: 'Show profiles that are currently excluded' } do |event|
    Storage.ensure_config_ready(event.server.id)
    excluded = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:excluded] }
    event.channel.send_message("_Currently excluding posts by:_ #{excluded.to_a.inspect}.")
  end
end
