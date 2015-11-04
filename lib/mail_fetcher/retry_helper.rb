module MailFetcher
  module RetryHelper
    def eventually(options = {})
      options = {:tries => 10, :delay => 1, :catch => []}.merge(options)
      last_error = nil
      start_time = Time.now.to_i
      options[:tries].times do |i|
        begin
          result = yield i
          return result if result
        rescue => e
          raise e unless Array(options[:catch]).any? { |type| e.is_a?(type) }
          last_error = e
        end
        timeout = options[:timeout] || (options[:tries] * options[:delay])
        if (Time.now.to_i - start_time) > timeout
          break
        else
          sleep(options[:delay])
        end
      end
      raise last_error if last_error
      nil
    end
  end
end
