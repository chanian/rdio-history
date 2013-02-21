require 'json'
require 'net/https'
require 'rdio-history/util'

module Rdio
  module Session
    class Fetcher
      include Rdio::API

      def self.get_session(username, password)
        # Initialize HTTPS object in SSL mode
        http = Net::HTTP.new(API_BASE_URL, 443)
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.use_ssl = true

        # Fetch an initial authorizationKey
        home_response = http.get(HOME_PATH)
        home = home_response.body
        auth_key = home[home.index('authorizationKey = "')..home.index('fbLocale =')]
        auth_key = auth_key.split(';')[0].split('= "')[1].split('"')[0]

        # Attempt a login
        data = ["username=#{username}",
                "password=#{password}",
                "method=#{SIGNIN_METHOD}",
                'remember=1',
                "_authorization_key=#{auth_key}"].join('&')

        result = http.post(SIGNIN_PATH, data, {})
        response_json = JSON.parse(result.body)
        if response_json['status'] == 'error'
          raise AuthorizationException.new(response_json['message'])
        end

        redirect_url = response_json['result']['redirect_url']

        # Parse the redirect, fetch token cookies
        home = http.post(redirect_url, '')

        # Load index page
        begin
          cookies = home.get_fields('Set-Cookie').join('').split(';').first
          logged_in = http.get(HOME_PATH, { 'Cookie' => cookies})

          # parse out the raw JSON user object directly from the response HTML
          # (╯°□°）╯︵ ┻━┻
          user = logged_in.body[logged_in.body.index('currentUser:')..(logged_in.body.index('serverInfo:') - 1)].strip!.chomp(',').split('currentUser:')[1]
          user = JSON.parse(user)
        rescue Exception => e
          raise ParseException.new('Error parsing page on login, likely do to scraping error')
        end

        return {
          :user_id => user['id'],
          :authorization_cookie => cookies,
          :authorization_key => user['authorizationKey']
        }
      end
    end

    class SessionException < Exception
    end
    class ParseException < SessionException
    end
    class AuthorizationException < SessionException
    end
  end
end
