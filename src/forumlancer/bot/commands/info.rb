# frozen_string_literal: true

require 'discordrb'
require 'marble'

require_relative '../commands'
require_relative '../../forum/scanner'

using Marble

# Implements the bot's about command.
module Commands
  command :info, { description: 'Show information about the bot', aliases: [:about] } \
  do |event|
    bot = event.bot

    event.send_embed do |embed|
      embed.title = 'Forumlancer'
      embed.description = "Providing #{'DiscoveryGC forum'.link(FORUM_PORTAL)} notifications in your server" \
                          " (and #{bot.servers.length - 1} others)"
      embed.thumbnail = bot.avatar
      embed.colour = bot.colour
      embed.add_field(name: 'Source code',
                      value: 'biqqles/forumlancer'.link(REPO),
                      inline: true)
      embed.add_field(name: 'Licensed under',
                      value: 'AGPLv3'.link('https://www.gnu.org/licenses/agpl-3.0.en.html'),
                      inline: true)
      embed.add_field(name: 'Deployed commit',
                      value: COMMIT.link("#{REPO}/commit/#{COMMIT}"),
                      inline: true)
    end
  end

  REPO = 'https://github.com/biqqles/forumlancer'
  COMMIT = `git rev-parse --short HEAD`.freeze
end
