# frozen_string_literal: true

# This file contains code to send notifications based on forum events.

require 'discordrb'
require 'marble'

require_relative '../bot'
require_relative '../storage'
require_relative 'scanner'

Notification = Struct.new(:server_id, :channel_id, :thread, :matched, :show_preview) do
  # Emit this notification as an embed in the nominated server and channel.
  include EasyLogging
  using Marble

  # @param bot [Discordrb::Bot] The bot to emit with.
  def emit(bot)
    return unless should_emit?

    begin
      bot.channel(channel_id)&.send_embed(&embed)
    rescue Discordrb::Errors::NoPermission
      logger.error "Unable to send notification in #{server_id}"
    else
      record_emission
    end
  end

  def embed # rubocop:disable Metrics/AbcSize
    proc do |embed|
      embed.title = "✉️  You've got mail"
      embed.description = "New post in #{thread.markdown.bold.italic}" \
                          "\nby #{thread.last_user.markdown.bold}"
      embed.description += "\n```#{thread.last_post}```" if show_preview

      embed.add_field(name: 'In subforum', value: thread.subforum.markdown)
      embed.add_field(name: 'Started by', value: thread.started_by.markdown)
      embed.add_field(name: 'Matched term', value: matched.inspect)

      embed.colour = Bot::COLOUR
      embed.timestamp = thread.last_active
    end
  end

  # Whether this notification needs to be emitted.
  # @return [Boolean]
  def should_emit?
    server_config = Storage.servers[server_id]
    return false if server_config[:excluded].include?(thread.last_user.full_url)

    past_notifications = Storage.notifications[:past]
    (past_notifications[uid] || 0) < thread.last_active.to_i
  end

  # Record the successful emission of this notification.
  def record_emission
    logger.info "Emitted notification for #{thread.short_title.inspect} in #{server_id}"

    Storage.notifications.open do |table|
      table[:past][uid] = thread.last_active.to_i
    end
  end

  # Represent this notification as a uniquely-identifying array.
  # @return [Array(Integer, Integer)]
  def uid
    [server_id, thread.id.to_i]
  end
end

# Create and emit notifications for all servers the bot is in.
# @param bot [Discordrb::Bot] The bot to emit with.
def notify(bot)
  configs = Storage.all_configs(bot)
  all_terms = configs.values.map { |c| c[:watchlist] }.to_set.flatten

  notifications = create_notifications(all_terms, configs)
  notifications.each { |n| n.emit(bot) }
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
  server_configs.each do |server_id, config|
    config[:watchlist].each do |term|
      matches[term.downcase].each do |thread|
        notifications.add Notification.new(server_id, config[:channel], thread,
                                           term, config[:show_preview])
      end
    end
  end
  notifications
end
