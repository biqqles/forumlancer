# frozen_string_literal: true

# Stores and validates secrets for the application.
module Secrets
  TOKEN = ENV['TOKEN']
  CLIENT = ENV['CLIENT']

  raise 'Token not provided' if TOKEN.nil?
  raise 'Client key not provided' if CLIENT.nil?
end
