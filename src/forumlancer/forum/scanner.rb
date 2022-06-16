# frozen_string_literal: true

# This file contains methods to fetch recent threads from the DiscoveryGC forums. It uses the "latest threads" sidebar.
# There also exists an RSS feed at <https://discoverygc.com/forums/syndication.php> but it seems to be very delayed.
# This approach is used because of a few factors:
#    - The forum activity is relatively low, so scraper outages of up to several hours are
#       tolerated because threads will not have dropped out of "latest threads"
#    - It minimises the number of requests to the web server
#    - It contains all the information we need in one place

require 'set'
require 'open-uri'

require 'oga'

require_relative 'objects'

# Fetch the 20 most recently posted-to threads.
# @return [Array<ForumThread>]
def fetch_recent_threads
  doc = fetch_url(FORUM_PORTAL)
  latest_threads = doc.css('.latestthreads_portal')
  latest_threads.map { |p| ForumThread.from_portal(p) }
end

# Fetch threads that match the given terms.
# @param matching [Set<String>] The set of terms to match for
# @return [{String => Array<ForumThread>}] A mapping of each (downcased) term to the ForumThreads that match it.
def fetch_matching_threads(matching)
  pattern = Regexp.new(Regexp.union(*matching).source, true)
  threads = fetch_recent_threads

  result = matching.to_h { |term| [term.downcase, []] }
  threads.each_with_object(result) do |thread, matches|
    thread.name.scan(pattern).each do |match|
      matches[match.downcase] << thread
    end
  end
end

# Fetch the document for the page at the given URL.
# @param url [String] The URL to fetch
# @return [Oga::XML::Document] The Oga document.
def fetch_url(url)
  Oga.parse_html(URI.parse(url).open)
end

FORUM_PORTAL = 'https://discoverygc.com/forums/portal.php'
