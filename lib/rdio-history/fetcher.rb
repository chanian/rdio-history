require 'json'
require 'net/https'
require 'rdio-history/session'
require 'rdio-history/item'
require 'rdio-history/util'

module Rdio
  module History
    class Fetcher
      include Rdio::API

      def initialize(session)
        @cursor = 0
        @rpp = 10
        @auth_key = session[:authorization_key]
        @auth_cookie = session[:authorization_cookie]
        @user_id = session[:user_id]
      end

      # Perform a single blocking history fetch
      # starting from the current cursor
      def fetch
        https = Net::HTTP.new(API_BASE_URL, 443)
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.use_ssl = true

        history = []
        headers = {
          'Cookie' => @auth_cookie
        }

        params = {
          'user' => "s#{@user_id}",
          'start' => @cursor,
          'count' => @rpp,
          'method' => HISTORY_METHOD,
          '_authorization_key' => @auth_key
        }
        data = params.map{|k,v| "#{k}=#{v}"}.join('&')
        resp = https.post(HISTORY_RESOURCE_URI, data, headers)

        # Verify the request went through
        if resp.code == '403'
          raise resp.message
        else
          data = JSON.parse(resp.body)
          if data.size > 0
            @cursor = data['result']['last_transaction']
            data['result']['sources'].each_with_index do |source, i|
              source['tracks'].each do |item|
                history << Item.new(item)
              end
            end
          end
        end
        return history
      end

    end
  end
end
