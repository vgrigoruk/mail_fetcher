require 'mail'
require_relative 'email_message'
module MailFetcher
  class GmailMessage < EmailMessage
    CONTENT_TYPE_PLAIN = /text\/plain/
    CONTENT_TYPE_HTML = /text\/html/

    def plain_text_body
      find_part_by_content_type(CONTENT_TYPE_PLAIN).body.decoded
    end

    def plain_text_urls
      plain_text_body.match(URL_PATTERN).to_a
    end

    def html_body
      find_part_by_content_type(CONTENT_TYPE_HTML).body.decoded
    end

    def html_urls
      html_body.scan(%r{href="(#{URL_PATTERN.source})"}).flatten
    end

    private

    def find_part_by_content_type(content_type)
      if email.content_type =~ content_type
        email
      else
        email.parts.find { |p| p.content_type =~ content_type }
      end
    end

    def email
      @email ||= begin
        raw_message = @connection.fetch(@message_id, 'RFC822.TEXT')[0].attr['RFC822.TEXT']
        Mail.new(raw_message)
      end
    end
  end
end