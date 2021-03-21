# frozen_string_literal: true

require_relative '../../storage'

# implements the bot's watchlist-related commands.
module Watch
  extend Discordrb::Commands::CommandContainer

  # Add a new watchword. Watchwords are case sensitive.
  command :watch, { description: 'Get notifications for threads with titles including this term' } \
  do |event, term|
    break unless assert_initialised(event)

    Storage::SERVERS.transaction do
      watchlist = Storage::SERVERS[event.server.id][:watchlist]

      break event.channel.send_message('_Missing argument_: `term`') if term.nil?
      break event.channel.send_message("_Already watching for_ #{term.inspect}!") if watchlist.include? term

      watchlist.add term
      event.channel.send_message("_OK, watching for_ #{term.inspect}.")
    end
  end

  command :unwatch, { description: 'No longer get notifications for threads including this term' } \
  do |event, term|
    Storage.ensure_config_ready(event.server.id)

    Storage::SERVERS.transaction do
      watchlist = Storage::SERVERS[event.server.id][:watchlist]

      break event.channel.send_message('_Missing argument_: `term`') if term.nil?
      break event.channel.send_message("_Wasn't watching for_ #{term.inspect}!") unless watchlist.include? term

      watchlist.delete term
      event.channel.send_message("_OK, no longer watching for_ #{term.inspect}.")
    end
  end

  command :watchlist, { description: 'Show the current watchlist' } do |event|
    break unless assert_initialised(event)

    watchlist = Storage::SERVERS.transaction { Storage::SERVERS[event.server.id][:watchlist] }

    break event.channel.send_message('_Watchlist empty._') if watchlist.empty?

    watchlist_contents = watchlist.map(&:inspect) * ', '
    event.channel.send_message("_Currently watching for:_ #{watchlist_contents}.")
  end

  # Assert that the bot is initialised and the server is ready to receive notifications.
  # @param event [Discordrb::Event] The event that triggered this check.
  # @return [Boolean] Whether the bot has been fully initialised.
  def self.assert_initialised(event)
    initialised = Storage.ensure_config_ready(event.server.id)
    unless initialised
      event.message.channel.send_message ":stop_sign: _Until I'm initialised you won't get notifications! " \
                                         'Run `f/init`._'
    end
    initialised
  end
end
