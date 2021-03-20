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
  def self.ensure_config_ready(server_id)
    SERVERS.transaction do
      SERVERS[server_id] ||= {}
      SERVERS[server_id][:channel] ||= nil  # redundant, but helps document the hash's keys
      SERVERS[server_id][:watchlist] ||= Set[]
      SERVERS[server_id][:excluded] ||= Set[]
    end
  end
end
