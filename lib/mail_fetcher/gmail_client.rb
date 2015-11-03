require 'mail'
require 'gmail_xoauth'
require 'faraday'
require_relative 'gmail_message'
require_relative 'retry_helper'

module MailFetcher
  class GmailClient

    def initialize(host='imap.gmail.com', port=993, account, client_id, token, secret)
      @host = host
      @port = port
      @account = account
      @client_id = client_id
      @token = token
      @secret = secret
    end

    def find(recipient, subject='', wait=1)
      @connection ||= authenticated_connection

      message_id = eventually(:tries => wait, :delay => 1) do
        begin
          @connection.examine('INBOX')
          search_filter = ['TO', recipient, 'SUBJECT', subject]
          results = @connection.search(search_filter)
          logger.error("Inbox contains #{results.length} messages matching search criteria") if results.length > 1
          results.first
        rescue => e
          logger.error("Error while trying trying to find a message in INBOX (#{e.message})")
          nil
        end
      end

      message_id ? GmailMessage.new(@connection, message_id) : nil
    end

    private

    def authenticated_connection
      connection = Net::IMAP.new(@host, @port, usessl = true, certs = nil, verify = false)
      connection.authenticate('XOAUTH2', @account, options)
      connection
    end

    def get_token
      params = {}
      params['client_id'] = @client_id
      params['client_secret'] = @secret
      params['refresh_token'] = @token
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