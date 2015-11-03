require_relative 'email_message'

module MailFetcher
  class MailCatcherMessage < EmailMessage
    def plain_text_body
      body(:plain)
    end

    def plain_text_urls
      plain_text_body.match(URL_PATTERN).to_a
    end

    def html_body
      body(:html)
    end

    def html_urls
      html_body.scan(%r{href="(#{URL_PATTERN.source})"}).flatten
    end

    private

    ## @param format - :html, :plain, :json
    def body(format=:json)
      @connection.get("/messages/#{@message_id}.#{format}").body
    end
  end
end