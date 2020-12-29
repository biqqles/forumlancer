# frozen_string_literal: true

# This file contains custom extensions to Discordrb's classes.

module Discordrb
  class Server
    def channel_map
      channels.to_h { |c| [c.id, c] }
    end
  end

  module Commands
    class CommandBot
      def avatar
        Discordrb::Webhooks::EmbedImage.new url: profile.avatar_url
      end
    end
  end
end
