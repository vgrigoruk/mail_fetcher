module MailFetcher
  class Client
    class << self
      attr_accessor :server_type, :max_wait_time, :host, :port, :client_id, :client_secret, :account, :refresh_token, :clean_inbox

      def initialize
        self.max_wait_time = 30
        self.clean_inbox = false
      end

      def configure
        yield self
      end

      def find(*args)
        client.find(*args)
      end

      protected

      def client
        @client ||= begin
          case server_type
            when :mail_catcher
              MailCatcherClient.new(host, port, clean_inbox = clean_inbox)
            when :gmail
              GmailClient.new(account, client_id, client_secret, refresh_token)
            else
              raise InvalidArgument.new('Unsupported mail_fetcher')
          end
        end
      end
    end
  end
end
