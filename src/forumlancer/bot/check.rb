# frozen_string_literal: true

require_relative '../storage'

# Checks that the bot is initialised and warns the user if it is not. Also provides logging of bot commands.
module Check
  extend Discordrb::EventContainer

  message start_with: 'f/' do |event|
    puts "Command '#{event.message}' invoked in #{event.server.id}"

    # disabled until I think of a way to do this without triggering simultaneous transactions
    # uninitialised = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:channel].nil? }
    # if uninitialised
    #   event.message.channel.send_message(':stop_sign: ' \
    #                                      "_Until I'm initialised you won't get notifications! Run `f/init`._")
    # end
  end
end
