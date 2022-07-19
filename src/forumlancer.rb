# frozen_string_literal: true

require 'date'

require 'discordrb'
require 'easy_logging'
require 'rufus-scheduler'

require_relative 'forumlancer/bot'
require_relative 'forumlancer/forum/notify'

# configure logging
# EasyLogging.level = Logger::DEBUG

# Main module for the program.
module Forumlancer
  include EasyLogging

  bot = Bot.new

  # schedule checking for notifications and redirect errors to the log
  scheduler = Rufus::Scheduler.new
  scheduler.every '1m' do
    bot.emit_notifications
  rescue StandardError => e
    logger.error e
  end

  # schedule deletion of old notification records
  scheduler.every '6h' do
    logger.info 'Deleting old notifications'

    Storage.notifications.open do |table|
      seven_days_ago = (Date.today - 7).to_time
      table[:past].delete_if do |_, time|
        Time.at(time) < seven_days_ago
      end
    end
  end

  # start the bot
  bot.emit_notifications
  bot.start
end
