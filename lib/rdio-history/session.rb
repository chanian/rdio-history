require 'json'
require 'net/https'
require 'rdio-history/util'

module Rdio
  module Session
    class Fetcher
      include Rdio::API

      def self.get_session
        # Initialize HTTPS object in SSL mode
        https = Net::HTTP.new(API_BASE_URL, 443)
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.use_ssl = true

        # Scrape the auth info off any page that sends back tokens
        home_response = https.get('/people/')

        # Strip out the autorization Cookie
        set_cookie = home_response.get_fields('Set-Cookie')
        cookie = set_cookie.join('').scan(/_a="(.+)?"/).first.first

        # Now strip out the (presumably) CSRF token
        home = home_response.body
        auth_key = home.scan(/authorizationKey"\: "(.+)?", "available_balance/)

        return {
          :authorization_cookie => cookie,
          :authorization_key => auth_key
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
