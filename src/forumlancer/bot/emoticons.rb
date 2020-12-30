# frozen_string_literal: true

require 'discordrb'

# This module allows the bot to handle Skype emoticons. Messages which contain one emoticon specifier, and nothing else,
# will prompt the bot to send an animated emoji of that emoticon to the same channel. The emojis behind this are stored
# in the bot's "home server".
module Emoticons
  extend Discordrb::EventContainer

  message start_with: '(', end_with: ')' do |event|
    emoji_name = event.message.content[1..-2] # text between brackets
    emoji = emoji_map(event.bot)[emoji_name]
    event.message.channel.send_message(emoji.mention) if emoji
  end

  def self.emoji_map(bot)
    @emoji_map ||= create_emoji_mapping(bot)
  end

  def self.create_emoji_mapping(bot)
    emojis = bot.home.emoji
    emoji_map = emojis.values.to_h { |e| [e.name, e] }
    emoji_map.tap do |map|
      # create any aliases
      map['nerd'] = map['nerdy']
    end
  end
end
