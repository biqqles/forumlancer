# frozen_string_literal: true

require 'easy_logging'

require_relative '../storage'
require_relative '../bot'

# Provides logging of bot commands.
module Logging
  extend Discordrb::EventContainer
  include EasyLogging

  message start_with: Bot::PREFIX do |event|
    logger.info "Command #{event.message.text.inspect} invoked in #{event.server.id}"
  end
end
