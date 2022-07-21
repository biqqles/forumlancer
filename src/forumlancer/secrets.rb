# frozen_string_literal: true

# Stores and validates secrets for the application.
module Secrets
  TOKEN = ENV['TOKEN']

  raise 'Token not provided' unless TOKEN
end
