# frozen_string_literal: true

require_relative '../storage'

# Checks that the bot is initialised and warns the user if it is not.
module Check
  extend Discordrb::EventContainer

  message start_with: 'f/' do |event|
    uninitialised = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:channel].nil? }
    if uninitialised
      event.message.channel.send_message(':stop_sign: ' \
                                         "_Until I'm initialised you won't get notifications! Run `f/init`._")
    end
  end
end
