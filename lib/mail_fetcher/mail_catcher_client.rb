require 'faraday_middleware'
require_relative 'retry_helper'
require_relative 'mail_catcher_message'

module MailFetcher
  class MailCatcherClient

    attr_accessor :logger

    def initialize(host, port, clean_inbox=false)
      base_url = "http://#{host}:#{port}"
      @connection = Faraday.new base_url do |conn|
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        conn.use :instrumentation
        conn.adapter Faraday.default_adapter
      end
      delete_all_messages if clean_inbox
    end

    ## @return MailCatcherMessage if message found or nil
    def find(recipient, subject='', wait=1)
      message_id = eventually(:tries => wait, :delay => 1) do
        message_data = all.find { |m| m['recipients'][0].include?(recipient) && m['subject'].include?(subject) }
        message_data ? message_data['id'] : nil
      end
      message_id ? MailCatcherMessage.new(@connection, message_id) : nil
    end

    private

    def delete_all_messages
      @connection.delete('/messages')
    end

    def all
      @connection.get('/messages').body
    end
  end
end
