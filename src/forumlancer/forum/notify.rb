# frozen_string_literal: true

# This file contains code to send notifications based on forum events.

require 'set'

require_relative '../storage'
require_relative 'scanner'

Notification = Struct.new(:server_id, :channel_id, :thread, :matched) do
  # Emit this notification as an embed in the nominated server and channel.
  # @param bot [Discordrb::Bot] The bot to emit with.
  def emit(bot)
    return unless should_emit?

    bot.channel(channel_id)&.send_embed do |embed|
      embed.title = ":envelope:  You've got mail"
      embed.description = "New post in ***#{thread.markdown}***\nby **#{thread.last_user.markdown}**"
      embed.colour = bot.colour
      embed.add_field(name: 'In subforum', value: thread.subforum.markdown)
      embed.add_field(name: 'Started by', value: thread.started_by.markdown)
      embed.add_field(name: 'Matched term', value: matched.inspect)
      embed.timestamp = thread.last_active
    end

    record_emission
  end

  # Whether this notification needs to be emitted.
  # @return [Boolean]
  def should_emit?
    server_config = Storage::SERVERS.transaction { Storage::SERVERS[server_id] }
    return false if server_config[:excluded].include?(thread.last_user.full_url)

    past_notifications = Storage::NOTIFICATIONS.transaction { Storage::NOTIFICATIONS[:past] }
    return false if past_notifications&.include?(uid)

    true
  end

  # Record the successful emission of this notification.
  def record_emission
    Storage::NOTIFICATIONS.transaction do
      Storage::NOTIFICATIONS[:past].add uid
    end
  end

  # Represent this notification as a uniquely-identifying array.
  # @return [Array(Integer, Integer, Integer)]
  def uid
    [server_id, thread.id.to_i, thread.last_active.to_i]
  end
end

# Create and emit notifications for all servers the bot is in.
# @param bot [Discordrb::Bot] The bot to emit with.
def notify(bot)
  configs = bot.servers.transform_values do |s|
    Storage.ensure_config_ready(s.id)
    # filter configs for servers the bot is in and has been initialised in
    config = Storage::SERVERS.transaction { Storage::SERVERS[s.id] }
    config unless config[:channel].nil?
  end.compact

  all_terms = configs.values.map { |c| c[:watchlist] }.to_set.flatten

  create_notifications(all_terms, configs).each { |n| n.emit(bot) }
end

# Create notifications for recent threads.
# A record of each notification created is saved to a set to prevent duplicates. If this wasn't done, notifications
# would be sent for each thread as long as it was in the latest threads, and also multiple times if multiple matches
# were made.
# @param matching [Set<String>] The set of terms to match for
# @param server_configs [{Int => Any}] Server configuration per server ID.
# @return [Set<Notification>]
def create_notifications(matching, server_configs)
  matches = fetch_matching_threads(matching)

  notifications = Set[]
  server_configs.map do |server_id, config|
    config[:watchlist].each do |term|
      matches[term].each do |thread|
        notifications.add Notification.new(server_id, config[:channel], thread, term)
      end
    end
  end
  notifications
end
