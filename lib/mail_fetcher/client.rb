module MailFetcher
  class Client
    class << self
      @@timeout = 30
      @@clean_inbox = false

      def configure
        yield self
      end

      def server_type=(backend_type)
        @@server_type = backend_type
      end

      def default_wait_time=(seconds)
        @@timeout = seconds
      end

      def host=(host)
        @@host = host
      end

      def port=(port)
        @@port = port
      end

      def clean_inbox=(should_clean)
        @@clean_inbox = should_clean
      end

      def find(*args)
        client.find(*args)
      end

      protected

      def client
        @@client ||= begin
          case @@server_type
            when :mail_catcher
              MailCatcherClient.new(@@host, @@port, clean_inbox = @@clean_inbox)
            when :gmail
              GmailClient.new(@@host, @@port, @@email, @@token, @@secret)
            else
              raise InvalidArgument.new('Unsupported mail_fetcher')
          end
        end
      end
    end
  end
end