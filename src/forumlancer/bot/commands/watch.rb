# frozen_string_literal: true

require_relative '../../storage'

# implements the bot's watchlist-related commands.
module Watch
  extend Discordrb::Commands::CommandContainer

  # Add a new watchword. Watchwords are case sensitive.
  command :watch, { description: 'Get notifications for threads with titles including this term' } \
  do |event, *terms|
    break unless assert_initialised(event)

    term = terms.join ' '

    Storage.servers.open do |table|
      watchlist = table[event.server.id][:watchlist]

      break event.respond('_Missing argument_: `term`') if term.empty?
      break event.respond("_Already watching for_ #{term.inspect}!") if watchlist.include? term

      watchlist.add term
      event.respond("_OK, watching for_ #{term.inspect}.")
    end
  end

  command :unwatch, { description: 'No longer get notifications for threads including this term' } \
  do |event, *terms|
    Storage.ensure_config_ready(event.server.id)

    term = terms.join ' '

    Storage.servers.open do |table|
      watchlist = table[event.server.id][:watchlist]

      break event.respond('_Missing argument_: `term`') if term.empty?
      break event.respond("_Wasn't watching for_ #{term.inspect}!") unless watchlist.include? term

      watchlist.delete term
      event.respond("_OK, no longer watching for_ #{term.inspect}.")
    end
  end

  command :watchlist, { description: 'Show the current watchlist' } do |event|
    break unless assert_initialised(event)

    watchlist = Storage.servers.open { |table| table[event.server.id][:watchlist] }

    break event.respond('_Watchlist empty._') if watchlist.nil? || watchlist.empty?

    watchlist_contents = watchlist.sort.map(&:inspect) * ', '
    event.respond("_Currently watching for:_ #{watchlist_contents}.")
  end

  # Assert that the bot is initialised and the server is ready to receive notifications.
  # @param event [Discordrb::Event] The event that triggered this check.
  # @return [Boolean] Whether the bot has been fully initialised.
  def self.assert_initialised(event)
    initialised = Storage.ensure_config_ready(event.server.id)
    unless initialised
      event.respond ":stop_sign: _Until I'm initialised you won't get notifications! " \
                                         'Run `f/init`._'
    end
    initialised
  end
end
