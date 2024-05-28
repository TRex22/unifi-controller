module UnifiController
  class Client
    # include HTTParty_with_cookies

    LOGIN_PATH = '/api/login'
    BACKUP_PATH = '/api/s/default/cmd/backup'

    attr_reader :username,
      :password,
      :base_path,
      :port,
      :raw_cookie,
      :verify_ssl

    def initialize(username:, password:, base_path:, port: 8443, verify_ssl: false)
      @username = username
      @password = password
      @base_path = base_path
      @port = port
      @verify_ssl = verify_ssl
    end

    def self.compatible_api_version
      'v1'
    end

    # This is the version of the API docs this client was built off-of
    def self.api_version
      'v1 2024-05-28'
    end

    def backup(days)
      start_time = get_micro_second_time

      login unless raw_cookie

      response = HTTParty.send(
        :post,
        "#{base_path}:#{port}#{BACKUP_PATH}",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          'Cookie': process_cookies,
          "X-Csrf-Token": process_cookies
        },
        body: Oj.to_json({ "days": days, "cmd": "backup" }),
        port: port,
        verify: verify_ssl
      )

      backup_path = response.dig("data").first.dig("url")

      stream = HTTParty.send(
        :get,
        "#{base_path}:#{port}#{backup_path}",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          'Cookie': process_cookies,
          "X-Csrf-Token": process_cookies
        },
        port: port,
        verify: verify_ssl
      )

      end_time = get_micro_second_time
      construct_response_stream(stream, start_time, end_time)
    end

    def login
      start_time = get_micro_second_time

      response = HTTParty.send(
        :post,
        "#{base_path}:#{port}#{LOGIN_PATH}",
        body: Oj.to_json({ username: username, password: password }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        port: port,
        verify: verify_ssl
      )

      end_time = get_micro_second_time

      @login_response = construct_response_object(response, LOGIN_PATH, start_time, end_time)

      @raw_cookie = @login_response.dig("headers").dig("set-cookie")
    end

    private

    def construct_response_object(response, path, start_time, end_time)
      {
        'body' => parse_body(response, path),
        'headers' => response.headers,
        'metadata' => construct_metadata(response, start_time, end_time)
      }
    end

    def construct_response_stream(response, start_time, end_time)
      {
        'body' => response.body,
        'headers' => response.headers,
        'metadata' => construct_metadata(response, start_time, end_time)
      }
    end

    def construct_metadata(response, start_time, end_time)
      total_time = end_time - start_time

      {
        'start_time' => start_time,
        'end_time' => end_time,
        'total_time' => total_time
      }
    end

    def body_is_present?(response)
      !body_is_missing?(response)
    end

    def body_is_missing?(response)
      response.body.nil? || response.body.empty?
    end

    def parse_body(response, path)
      parsed_response = Oj.load(response.body) # Purposely not using HTTParty

      if parsed_response.dig(path.to_s)
        parsed_response.dig(path.to_s)
      else
        parsed_response
      end
    rescue Oj::LoadError => _e
      response.body
    end

    def parse_cookie(set_cookie_str, key)
      value = nil
      expiry = nil

      set_cookie_str.each do |item|
        if item.include?(key)
          value = item.split('; ').first.split('=').last

          if item.include?('Expires') || item.include?('expires')
            item.split('; ').each do |sub_item|
              if sub_item.include?('Expires') || sub_item.include?('expires')
                expiry = Time.parse(sub_item.gsub('expires=', '').gsub('Expires=', ''))
              end
            end
          end
        end
      end

      [value, expiry]
    end

    def process_cookies
      # Cookies are always a single string separated by spaces
      raw_cookie.map { |item| item.split('; ').first }.join('; ')
    end

    def get_micro_second_time
      (Time.now.to_f * 1000000).to_i
    end

    def construct_base_path(path, params)
      constructed_path = "#{base_path}/#{path}"

      if params == {}
        constructed_path
      else
        "#{constructed_path}?#{process_params(params)}"
      end
    end

    def process_params(params)
      params.keys.map { |key| "#{key}=#{params[key]}" }.join('&')
    end
  end
end
