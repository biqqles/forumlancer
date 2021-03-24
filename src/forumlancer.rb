# frozen_string_literal: true

require 'discordrb'
require 'easy_logging'
require 'pidfile'
require 'rufus-scheduler'

require_relative 'forumlancer/bot'
require_relative 'forumlancer/forum/notify'

# configure logging
EasyLogging.level = Logger::DEBUG

# Main module for the program.
module Forumlancer
  include EasyLogging

  # prevent multiple instances from running
  @pf = PidFile.new

  # start checking for notifications and redirect errors to the log
  scheduler = Rufus::Scheduler.new
  scheduler.every '1m' do
    logger.debug 'Checking notifications'
    notify Bot::BOT
  rescue StandardError => e
    logger.error e
  end

  # start the bot
  notify Bot::BOT
  Bot.start
end
