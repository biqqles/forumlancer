# frozen_string_literal: true

require 'discordrb'
require 'easy_logging'

require_relative 'secrets'

# Forumlancer's bot.
module Bot
  include EasyLogging

  HOME_SERVER = 713_179_742_978_834_452 # Planet Gammu
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

  def self.start
    logger.info 'Starting bot'
    logger.info "Bot in #{BOT.servers.count} servers"
    BOT.join
  end

  # add commands to bot
  require_relative 'bot/commands/ignore'
  require_relative 'bot/commands/info'
  require_relative 'bot/commands/init'
  require_relative 'bot/commands/watch'
  require_relative 'bot/logging'
  require_relative 'bot/emoticons'

  BOT = Bot.new
  BOT.include! Emoticons
  BOT.include! Ignore
  BOT.include! Info
  BOT.include! Init
  BOT.include! Logging
  BOT.include! Watch
end
