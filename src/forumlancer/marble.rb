# frozen_string_literal: true

# My Markdown formatter. Eventually I will spin this off into its own gem.
module Marble
  # TODO: consider String extension methods
  # TODO: consider compatibility for older Rubies. E.g. .map { |c| [c, "\\#{c}"] }.to_h for Ruby < 2.6
  ESCAPED = %w{( ) * [ \\ ] _ ` | ~}.to_h { |c| [c, "\\#{c}"] }
  TO_ESCAPE = Regexp.union(ESCAPED.keys)

  # Return a string with Markdown syntax removed.
  # @param str [String]
  # @return [String]
  def self.escape(str)
    str.gsub(TO_ESCAPE, ESCAPED)
  end

  # Create a Markdown link.
  # @param text [String]
  # @param url [String]
  # @return [String]
  def self.link(text, url)
    "[#{escape(text)}](#{url})"
  end
end
