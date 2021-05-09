# frozen_string_literal: true

require 'discordrb'
require 'marble'

require_relative '../../forum/objects'

using Marble

# Implements the bot's ignore feature.
module Ignore
  extend Discordrb::Commands::CommandContainer

  command :ignore, { description: 'Exclude a forum account from causing notifications' } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      ignored = Storage::SERVERS[event.server.id][:excluded]

      break event.respond('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url).name.escape

      break event.respond("_Already ignored: __#{user}__!_") if ignored.include? profile_url

      ignored.add profile_url
      event.respond("_OK, ignoring posts by __#{user}__._")
    end
  end

  command :unignore, { description: 'Allow posts from this account to cause notifications' } \
  do |event, profile_url|
    Storage.ensure_config_ready(event.server.id)
    Storage::SERVERS.transaction do
      ignored = Storage::SERVERS[event.server.id][:excluded]

      break event.respond('_Missing argument:_ `profile_url`') if profile_url.nil?

      user = ForumUser.from_profile_url(profile_url).name.escape

      break event.respond("_Hadn't ignored: __#{user}__!_") unless ignored.include? profile_url

      ignored.delete profile_url
      event.respond("_OK, no longer ignoring posts by __#{user}__._")
    end
  end

  command :ignored, { description: 'Show profiles that are currently ignored' } do |event|
    Storage.ensure_config_ready(event.server.id)
    ignored = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:excluded] }
    event.respond("_Currently ignoring posts by:_ #{ignored.sort.map(&:inspect) * ', '}.")
  end
end
