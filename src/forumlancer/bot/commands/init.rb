# frozen_string_literal: true

require 'discordrb'

require_relative '../commands'
require_relative '../../storage'

# Implements the bot's init command.
module Commands
  command :init, { description: 'Configure the bot to use this channel for notifications' } \
  do |event|
    server = event.message.server
    channel = event.message.channel

    Storage.ensure_config_ready(server.id)
    Storage.servers.open do |table|
      table[server.id][:channel] = channel.id
    end
    channel.send_message("_OK, I'll use #{channel.mention} for my notifications_")
  end
end
