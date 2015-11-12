require_relative 'gmail_client'
require_relative 'mail_catcher_client'
require 'yaml'

module MailFetcher
  class Client
    class << self
      attr_accessor :server_type, :max_wait_time, :host, :port, :client_id, :client_secret, :account, :refresh_token, :clean_inbox, :logger

      def configure
        self.max_wait_time = 30
        self.clean_inbox = false
        yield self
        if debug_mode && !self.logger
          self.logger = self.create_default_logger
        end
      end

      def find(*args)
        client.find(*args)
      end

      protected

      def client
        @client ||= create_client
      end

      private

      def create_client
        case self.server_type
          when :mail_catcher
            _client = MailCatcherClient.new(host, port, clean_inbox = clean_inbox)
          when :gmail
            _client = GmailClient.new(account, client_id, client_secret, refresh_token)
          else
            raise InvalidArgument.new('Unsupported server type')
        end
        _client.logger = logger
        _client
      end

      def debug_mode
        YAML.load(ENV.fetch('DEBUG', 'false'))
      end

      def create_default_logger
        _logger = Logger.new(STDOUT)
        _logger.level = Logger::DEBUG
        _logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{severity}][#{datetime}] - #{msg}\n"
        end
        _logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        _logger
      end
    end
  end
end
