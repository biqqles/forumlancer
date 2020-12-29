# frozen_string_literal: true

require 'discordrb'

require_relative '../../storage'

# Implements the bot's init command.
module Init
  extend Discordrb::Commands::CommandContainer

  command :init, { description: 'Configure the bot to use this channel for notifications' } \
  do |event|
    server = event.message.server
    channel = event.message.channel

    Storage.ensure_config_ready(server.id)
    Storage::SERVERS.transaction do
      Storage::SERVERS[server.id][:channel] = channel.id
    end
    channel.send_message("_OK, I'll use #{channel.mention} for my notifications_")
  end
end
