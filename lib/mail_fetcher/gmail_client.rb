require 'mail'
require 'gmail_xoauth'
require 'faraday'
require_relative 'gmail_message'
require_relative 'retry_helper'

module MailFetcher
  class GmailClient
    include MailFetcher::RetryHelper

    HOST = 'imap.gmail.com'
    PORT = 993

    attr_accessor :logger

    def initialize(account, client_id, client_secret, refresh_token)
      @account = account
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
    end

    def find(recipient, subject='', wait=MailFetcher::Client.max_wait_time)
      @connection ||= authenticated_connection

      message_id = eventually(:tries => wait, :delay => 1) do
        begin
          @connection.examine('INBOX')
          search_filter = ['TO', recipient, 'SUBJECT', subject]
          results = @connection.search(search_filter)
          logger.debug("Inbox contains #{results.length} messages matching search criteria") if logger
          results.first
        rescue => e
          logger.error("Error while trying trying to find a message in INBOX (#{e.message})") if logger
          nil
        end
      end

      message_id ? GmailMessage.new(@connection, message_id) : nil
    end

    private

    def authenticated_connection
      connection = Net::IMAP.new(HOST, PORT, usessl = true, certs = nil, verify = false)
      connection.authenticate('XOAUTH2', @account, get_access_token)
      connection
    end

    def get_access_token
      params = {}
      params['client_id'] = @client_id
      params['client_secret'] = @client_secret
      params['refresh_token'] = @refresh_token
      params['grant_type'] = 'refresh_token'
      request_url = 'https://accounts.google.com'
      conn = Faraday.new(:url => request_url) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end

      response = conn.post('/o/oauth2/token', params)
      JSON.parse(response.body)['access_token']
    end
  end
end
