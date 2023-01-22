# frozen_string_literal: true

require 'discordrb'
require 'marble'

require_relative '../commands'
require_relative '../../storage'

# Implements commands for general configuration.
module Commands
  using Marble

  command :init, { description: 'Configure the bot to use this channel for notifications' } \
  do |event|
    server = event.message.server
    channel = event.message.channel

    Storage.ensure_config_ready(server.id)
    Storage.servers.open do |table|
      table[server.id][:channel] = channel.id
    end
    channel.send_message("OK, I'll use #{channel.mention} for my notifications".italics)
  end

  command :preview, { description: 'Configure whether notifications include a preview of post content' }\
  do |event, action|
    store = case action
            when 'on' then true
            when 'off' then false
            end
    break if store.nil?

    server = event.message.server

    Storage.ensure_config_ready(server.id)
    Storage.servers.open do |table|
      table[server.id][:show_preview] = store
    end

    event.respond("Preview message content in notifications: #{action.bold}".italics)
  end
end
