# frozen_string_literal: true

# This file contains code to send notifications based on forum events.

require 'set'

require_relative '../storage'
require_relative 'scanner'

Notification = Struct.new(:server_id, :channel_id, :thread, :matched) do
  # Emit this notification as an embed in the nominated server and channel.
  # @param bot [Discordrb::Bot] The bot to emit with.
  def emit(bot)
    server = bot.servers[server_id]
    raise "Bot not in server #{server_id}" unless server

    excluded = Storage::SERVERS.transaction { Storage::SERVERS[server_id][:excluded] }
    return if excluded.include? thread.last_user

    server.channel_map[channel_id].send_embed do |embed|
      embed.title = ":envelope:  You've got mail"
      embed.description = "New post in ***#{thread.markdown}***\nby **#{thread.last_user.markdown}**"
      embed.colour = bot.colour
      embed.add_field(name: 'Subforum', value: thread.subforum.markdown)
      embed.add_field(name: 'Started by', value: thread.started_by.markdown)
      embed.add_field(name: 'Matched watchword', value: matched.inspect)
      embed.timestamp = thread.last_active
    end
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

  notifications = Set[] # TODO: possibly a way to simplify this block
  Storage::NOTIFICATIONS.transaction do
    server_configs.map do |server_id, config|
      config[:watchlist].each do |term|
        matches[term].each do |thread|
          notification = Notification.new(server_id, config[:channel], thread, term)
          notifications.add(notification) if  # ignore if already sent to this server
            Storage::NOTIFICATIONS[:past].add?([server_id, thread.full_url, thread.last_active])
        end
      end
    end
  end
  notifications
end
