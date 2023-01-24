# frozen_string_literal: true

# This file defines objects for various "things" on the forum.

require 'marble'

# Mixin for a forum object which at minimum has a URL and an ID.
module ForumObject
  using Marble

  # This object's ID.
  # @return [String]
  def id
    full_url.delete('^0-9')
  end

  # A Markdown link to this object.
  # @return [String]
  def markdown
    Marble.link(name.escape, full_url)
  end
end

# A subforum.
Subforum = Struct.new(:full_url, :name) do
  include ForumObject
end

# A forum user. `full_url` is a link to their profile.
ForumUser = Struct.new(:full_url, :name) do
  include ForumObject

  def self.from_profile_url(profile_url)
    profile = fetch_url(profile_url)
    name = profile.css('.proname').text

    ForumUser.new(profile_url, name)
  end
end

# A thread on the forum.
ForumThread = Struct.new(:portal_url, :short_title, :last_user, :last_active) do
  include ForumObject

  # Alternative constructor from a ".latestthreads_portal" div.
  # @param portal [Oga::XML::Element] The ".latestthreads_portal" element.
  # @return [ForumThread] The new ForumThread struct.
  def self.from_portal(portal)
    thread = portal.at_css('strong a') # retaining "action=lastpost" is intentional
    metadata = portal.at_css('span')
    user = metadata.at_css('a')

    timestamp = case metadata.at_css('span')
                in nil then metadata.css('br')[1].next.text
                in some then some['title'] + some.next.text
                end

    time = Time.strptime(timestamp.strip, '%m-%d-%Y, %I:%M %p')

    ForumThread.new(thread['href'], thread.text, ForumUser.new(user['href'], user.text), time)
  end

  # Human-readable url, redirected from the portal ("action=lastpost") url. (memoized.)
  # @return [String]
  def full_url
    URI.parse(portal_url).read.base_uri.to_s
  end

  # URL of threaded version of the thread, used for fetching the last post.
  # TODO get number of posts from this
  # @return [String]
  def threaded_url
    full_url.sub('?', '?mode=threaded&')
  end

  def id
    portal_url.delete('^0-9')
  end

  # The document for the archive of this thread. (memoized).
  # @return [Oga::XML::Document]
  def doc
    @doc ||= fetch_url(threaded_url)
  end

  # This thread's full title.
  # @return [String]
  # noinspection RubyNilAnalysis
  def name
    short_title unless short_title.end_with? '...'
    doc.at_css('title').text
  end

  # The user who started this thread.
  # noinspection RubyNilAnalysis
  # @return [ForumUser]
  def started_by
    user = doc.at_css('.smalltext a')
    ForumUser.new(user['href'], user.text)
  end

  # The subforum this thread is in.
  # @return [Subforum]
  def subforum
    link = doc.css('.navigation a').last
    Subforum.new(link['href'], link.text)
  end

  # The truncated text of the last post in this thread.
  # @return String
  def last_post(truncate: 600)
    message = doc.at_css('.post_body').text
    message.length > truncate ? "#{message[..truncate]}..." : message
  end
end

FORUM_ROOT = 'https://discoverygc.com/forums/'
FORUM_PORTAL = "#{FORUM_ROOT}portal.php".freeze
