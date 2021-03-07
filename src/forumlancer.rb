# frozen_string_literal: true

require 'logger'

require 'discordrb'
require 'rufus-scheduler'

require_relative 'forumlancer/bot'
require_relative 'forumlancer/forum/notify'

# Main module for the program.
module Forumlancer
  logger = Logger.new(STDOUT)

  scheduler = Rufus::Scheduler.new
  scheduler.every '5m' do
    logger.info('Checking notifications')
    notify Bot::BOT
  end

  notify Bot::BOT
  Bot.start
end
