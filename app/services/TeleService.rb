class TeleService
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue => e
      request = Rack::Request.new(env)
      text = { url: request.url,
               params: request.params&.as_json,
               error: e }.as_json
      self.class.send_message(text)
      raise e
    end
  end

  def self.send_message(message)
    message = message.merge({ env: Rails.env })
    str = "https://api.telegram.org/#{ENV['TELEGRAM_TOKEN']}/sendMessage?text=#{ERB::Util.url_encode(message)}&chat_id=#{ENV['TELEGRAM_CHAT_ID']}"
    url = URI.parse(str)
    Thread.new do
      Net::HTTP.get(url)
    end
  end

end
