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

require 'nokogiri'

require_relative 'objects'

FORUM_PORTAL = 'https://discoverygc.com/forums/portal.php'

# Fetch the 20 most recently posted-to threads.
# @return [Array<ForumThread>]
def fetch_recent_threads
  doc = fetch_url(FORUM_PORTAL)
  latest_threads = doc.css('.latestthreads_portal')
  latest_threads.map { |p| ForumThread.from_portal(p) }
end

# Fetch threads that match the given terms.
# @param matching [Set<String>] The set of terms to match for
# @return [{String => ForumThread}] A mapping of matched term to ForumThread.
def fetch_matching_threads(matching)
  threads = fetch_recent_threads

  matches = Hash.new { |h, k| h[k] = [] }

  threads.each do |thread|
    title_terms = thread.name.split.to_set
    (title_terms & matching).each { |m| matches[m] << thread }
  end
  matches
end

# Fetch the document for the page at the given URL.
# @param url [String] The URL to fetch
# @return [Nokogiri::HTML::Document] The Nokogiri document.
def fetch_url(url)
  Nokogiri::HTML(URI.parse(url).open)
end
