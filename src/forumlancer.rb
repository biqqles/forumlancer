# frozen_string_literal: true

require 'discordrb'
require 'easy_logging'
require 'rufus-scheduler'

require_relative 'forumlancer/bot'
require_relative 'forumlancer/forum/notify'

# configure logging
EasyLogging.level = Logger::DEBUG

# Main module for the program.
module Forumlancer
  include EasyLogging

  scheduler = Rufus::Scheduler.new
  scheduler.every '1m' do
    logger.debug 'Checking notifications'
    notify Bot::BOT
  rescue StandardError => e
    logger.error e
  end

  notify Bot::BOT
  Bot.start
end
