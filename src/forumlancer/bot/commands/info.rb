# frozen_string_literal: true

require 'discordrb'

require_relative '../../forum/scanner'

# Implements the bot's about command.
module Info
  extend Discordrb::Commands::CommandContainer

  command :info, { description: 'Show information about the bot', aliases: [:about] } \
  do |event|
    event.message.channel.send_embed do |embed|
      embed.title = 'Forumlancer'
      embed.description = "Providing [DiscoveryGC](#{FORUM_PORTAL}) forum notifications in your server"
      embed.thumbnail = event.bot.avatar
      embed.colour = event.bot.colour
      embed.add_field(name: 'Source code',
                      value: '[biqqles/forumlancer](https://github.com/biqqles/forumlancer)',
                      inline: true)
      embed.add_field(name: 'Licensed under',
                      value: '[AGPLv3](https://www.gnu.org/licenses/agpl-3.0.en.html)',
                      inline: true)
      embed.add_field(name: 'Deployed commit',
                      value: "[#{COMMIT}](https://github.com/biqqles/forumlancer/commit/#{COMMIT})",
                      inline: true)
    end
  end

  COMMIT = (ENV['HEROKU_SLUG_COMMIT'] || `git rev-parse HEAD`).slice(0..6).freeze
end
