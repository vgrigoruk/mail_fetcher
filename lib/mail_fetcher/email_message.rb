module MailFetcher
  class EmailMessage
    URL_PATTERN = /https?:\/\/[_a-zA-Z0-9\.\/?=&-]+/

    def initialize(connection, message_id)
      @connection = connection
      @message_id = message_id
    end
  end
end
