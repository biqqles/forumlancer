# frozen_string_literal: true

require 'discordrb'

# Container for commands exposed by the bot to the user.
module Commands
  extend Discordrb::Commands::CommandContainer

  require_relative 'commands/ignore'
  require_relative 'commands/info'
  require_relative 'commands/init'
  require_relative 'commands/watch'
end
