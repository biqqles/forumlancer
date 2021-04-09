# frozen_string_literal: true

require 'discordrb'
require 'marble'

require_relative '../../forum/objects'

using Marble

# Implements the bot's exclusion-related commands.
module Exclude
  extend Discordrb::Commands::CommandContainer

  command :exclude, { description: 'Exclude a forum account from causing notifications' } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      excluded = Storage::SERVERS[event.server.id][:excluded]

      break event.respond('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url).name.escape

      break event.respond("_Already excluded: __#{user}__!_") if excluded.include? profile_url

      excluded.add profile_url
      event.respond("_OK, excluding posts by __#{user}__._")
    end
  end

  command :include,
          { description: 'Allow posts from this account to cause notifications', aliases: [:unexclude] } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      excluded = Storage::SERVERS[event.server.id][:excluded]

      break event.respond('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url).name.escape

      break event.respond("_Hadn't excluded: __#{user}__!_") unless excluded.include? profile_url

      excluded.delete profile_url
      event.respond("_OK, no longer excluding posts by __#{user}__._")
    end
  end

  command :excluded, { description: 'Show profiles that are currently excluded' } do |event|
    Storage.ensure_config_ready(event.server.id)
    excluded = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:excluded] }
    event.respond("_Currently excluding posts by:_ #{excluded.to_a.inspect}.")
  end
end
