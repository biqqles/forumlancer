# frozen_string_literal: true

require 'discordrb'
require 'easy_logging'

require_relative 'forum/notify'
require_relative 'secrets'

# Forumlancer's bot.
class Bot < Discordrb::Commands::CommandBot
  HOME_SERVER = 713_179_742_978_834_452 # Planet Gammu
  COLOUR = 0xc80f55
  PREFIX = 'f/'

  include EasyLogging

  require_relative 'bot/commands'
  require_relative 'bot/emoticons'
  require_relative 'bot/logging'

  def initialize
    super token: Secrets::TOKEN, client_id: Secrets::TOKEN, prefix: PREFIX

    ready { self.watching = "the forums. #{PREFIX}help" }

    # add containers
    include! Commands
    include! Emoticons
    include! Logging

    run true
  end

  def start
    logger.info 'Starting bot'
    logger.info "Bot in #{servers.count} servers"
    join
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

  def emit_notifications
    logger.debug 'Checking notifications'
    notify self
  end
end
