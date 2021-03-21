# frozen_string_literal: true

require 'easy_logging'

require_relative '../storage'

# Provides logging of bot commands.
module Logging
  extend Discordrb::EventContainer
  include EasyLogging

  message start_with: 'f/' do |event|
    logger.info "Command #{event.message.text.inspect} invoked in #{event.server.id}"
  end
end
