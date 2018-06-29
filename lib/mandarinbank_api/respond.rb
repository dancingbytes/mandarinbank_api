module MandarinbankApi

  class Respond

    def initialize(request)

      @error  = nil
      @result = []
      prepare_request(request)

    end

    def success?
      @error.nil?
    end

    def failure?
      !success?
    end

    alias :error? :failure?

    def error
      @error
    end

    def result
      @result
    end

    def result!

      raise error if failure?
      result

    end

    private

    def prepare_request(request)

      if request.instance_of?(::Net::HTTPOK)
        prepare_http(request)
      else
        prepare_error(request)
     end

    end

    def prepare_http(request)

      begin

        @result = ::Oj.load(request.read_body)
        @error  = nil

      rescue ::Exception => ex

        @result = []
        @error  = ex

      end

    end

    def prepare_error(request)

      @result = []

      if request.instance_of?(::Net::HTTPBadRequest)

        begin
          @error = ::Oj.load(request.read_body)
        rescue ::Exception => ex
          @error  = ex
        end

      else
        @error = request
      end

    end

  end

end