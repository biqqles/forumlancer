# frozen_string_literal: true

require 'set'
require 'yaml/store'

# Stores configuration for the application.
module Storage
  SERVERS = YAML::Store.new('servers.store') # used for storing per-server configuration
  NOTIFICATIONS = YAML::Store.new('notifications.store') # used for storing past notifications

  # initialise notifications. TODO: delete outdated
  NOTIFICATIONS.transaction do
    NOTIFICATIONS[:past] ||= Set[]
  end

  # Ensure that the server configuration for the given server has been set up for the latest schema.
  # This method MUST be called before transactions with SERVER.
  # @param server_id [Integer] The server ID to set up config for.
  # @return [Boolean] Whether the bot has been fully initialised and is ready to send notifications.
  def self.ensure_config_ready(server_id)
    channel = nil
    SERVERS.transaction do
      SERVERS[server_id] ||= {}
      channel = SERVERS[server_id][:channel] ||= nil  # redundant, but helps document the hash's keys
      SERVERS[server_id][:watchlist] ||= Set[]
      SERVERS[server_id][:excluded] ||= Set[]
    end
    !channel.nil?
  end

  # Fetch the configuration for each server the bot has been initialised in.
  # @param bot [Discordrb::Bot] The bot instance whose servers to check.
  # @return [{Integer => Hash}] A map of server ID to that server's configuration.
  def self.all_configs(bot)
    bot.servers.transform_values do |s|
      ensure_config_ready(s.id)
      config = SERVERS.transaction { SERVERS[s.id] }
      config unless config[:channel].nil?  # filter for servers has been initialised in
    end.compact
  end
end
