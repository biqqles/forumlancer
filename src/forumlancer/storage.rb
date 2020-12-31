# frozen_string_literal: true

require 'set'
require 'yaml'
require 'yaml/store'

require 'redis'

# Stores configuration for the application.
module Storage

  # A dead simple PStore implementation that hooks Store#dump to save YAML to Redis as well as a file. This is required
  # because Heroku does not support creating persistent files. Heroku Redis is not truly persistent either but it's
  # a lot more persistent than files are and good enough for this bot, at least to begin with. Because this class loads
  # and stores to both file and Redis, data should only be lost if the app Dyno and Redis VM go down simultaneously.
  class RedisStore < YAML::Store
    REDIS = Redis.new(url: ENV['REDIS_URL'])

    # Try to load this store from Redis, but fall back on the usual file.
    def load(content)
      redis_yaml = REDIS.get(@filename)
      redis_yaml ? YAML.load(redis_yaml) : super(content)
    end

    # Place this store in Redis, in addition to writing to the usual file.
    def dump(table)
      super.tap do |dumped|
        REDIS.set(@filename, dumped)
      end
    end
  end

  SERVERS = RedisStore.new('servers.store') # used for storing per-server configuration
  NOTIFICATIONS = RedisStore.new('notifications.store') # used for storing past notifications

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
