# frozen_string_literal: true

require 'discordrb'

require_relative '../../forum/scanner'
require_relative '../../marble'

# Implements the bot's about command.
module Info
  extend Discordrb::Commands::CommandContainer

  command :info, { description: 'Show information about the bot', aliases: [:about] } \
  do |event|
    event.message.channel.send_embed do |embed|
      embed.title = 'Forumlancer'
      embed.description = "Providing #{Marble.link('DiscoveryGC forum', FORUM_PORTAL)} notifications in your server"
      embed.thumbnail = event.bot.avatar
      embed.colour = event.bot.colour
      embed.add_field(name: 'Source code',
                      value: Marble.link('biqqles/forumlancer', REPO),
                      inline: true)
      embed.add_field(name: 'Licensed under',
                      value: Marble.link('AGPLv3', 'https://www.gnu.org/licenses/agpl-3.0.en.html'),
                      inline: true)
      embed.add_field(name: 'Deployed commit',
                      value: Marble.link(COMMIT, "#{REPO}/commit/#{COMMIT}"),
                      inline: true)
    end
  end

  REPO = 'https://github.com/biqqles/forumlancer'
  COMMIT = `git rev-parse --short HEAD`.freeze
end
