module MandarinbankApi

  class Request

    DEBUG         = ::ENV.fetch("MANDARIN_BANK_DEBUG") { 'true' }.freeze
    VERIFY_MODE   = ::ENV.fetch("MANDARIN_BANK_VERIFY_MODE") { 'true' }.freeze
    TIMEOUT       = ::ENV.fetch("MANDARIN_BANK_TIMEOUT") { 30 }.to_i.freeze
    USER_AGENT    = ::ENV.fetch("MANDARIN_BANK_USER_AGENT") { "RubyMB #{::MandarinbankApi::VERSION}" }.freeze
    CONTENT_TYPE  = 'application/json'.freeze

    def self.call(url, auth_key, params)
      new(url, auth_key).call(params)
    end

    def initialize(url, auth_key)

      uri       = URI(url)
      @http     = ::Net::HTTP.new(uri.host, uri.port)
      @request  = ::Net::HTTP::Post.new(uri.request_uri)

      @auth_key = auth_key

      set_request_params
      set_http_params

    end

    def call(params)

      # Данные запроса в формате JSON
      @request.body = ::Oj.dump(params)

      begin
        @http.request @request
      rescue Exception => ex
        ex
      end

    end

    private

    # Настройки запроса
    def set_http_params

      @http.set_debug_output($stdout) if DEBUG

      @http.use_ssl      = true
      @http.verify_mode  = VERIFY_MODE

      @http.open_timeout = TIMEOUT
      @http.read_timeout = TIMEOUT
      @http.ssl_timeout  = TIMEOUT

      self

    end

    # Заголовоки запроса
    def set_request_params

      @request['User-Agent']   = USER_AGENT
      @request['Accept']       = "*/*"
      @request['Content-Type'] = CONTENT_TYPE
      @request['X-Auth']       = @auth_key

      self

    end

  end

end