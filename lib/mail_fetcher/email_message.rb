module MailFetcher
  class EmailMessage
    URL_PATTERN = /https?:\/\/[\S]+/

    def initialize(connection, message_id)
      @connection = connection
      @message_id = message_id
    end
  end
end