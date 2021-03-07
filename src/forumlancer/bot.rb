# frozen_string_literal: true

require 'discordrb'

require_relative 'secrets'
require_relative 'bot/commands/exclude'
require_relative 'bot/commands/info'
require_relative 'bot/commands/init'
require_relative 'bot/commands/watch'
require_relative 'bot/check'
require_relative 'bot/emoticons'

# Forumlancer's bot.
module Bot
  HOME_SERVER = 713_179_742_978_834_452  # Planet Gammu
  COLOUR = 0xc80f55
  PREFIX = 'f/'

  class Bot < Discordrb::Commands::CommandBot
    def initialize
      super token: Secrets::TOKEN, client_id: Secrets::TOKEN, prefix: PREFIX
      run true
      self.watching = "the forums. #{PREFIX}help"
    end

    # The bot's theme colour.
    # @return [Integer]
    def colour
      COLOUR
    end

    # The bot's home server.
    # @return [Discordrb::Server]
    def home
      servers[HOME_SERVER]
    end

    # The bot's avatar image.
    # @return [Discordrb::Webhooks::EmbedImage]
    def avatar
      Discordrb::Webhooks::EmbedImage.new url: profile.avatar_url
    end
  end

  BOT = Bot.new
  BOT.include! Check  # disabled until I think of a better way to do this
  BOT.include! Exclude
  BOT.include! Info
  BOT.include! Init
  BOT.include! Emoticons
  BOT.include! Watch

  def self.start
    puts 'Starting bot'
    BOT.join
  end
end
