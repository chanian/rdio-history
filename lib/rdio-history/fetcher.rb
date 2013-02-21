require 'json'
require 'net/http'
require 'net/https'
require 'rdio-history/session'
require 'rdio-history/item'
require 'rdio-history/util'

module Rdio
  module History
    class Fetcher
      include Rdio::API

      def initialize(session)
        @auth_key = session[:authorization_key]
        @auth_cookie = session[:authorization_cookie]
        @user_id = session[:user_id]
      end

      def fetch(max_requests = 1)
        http = Net::HTTP.new(API_BASE_URL, 80)
        start_index = 1
        rpp = 1
        history = []

        (1..max_requests).each do |request_no|
          cookie = @auth_cookie
          headers = {
            'Cookie' => cookie
          }

          params = {
            'user' => "s#{@user_id}",
            'start' => start_index,
            'count' => rpp,
            'method' => HISTORY_METHOD,
            '_authorization_key' => @auth_key
          }
          data = params.map{|k,v| "#{k}=#{v}"}.join('&')
          resp = http.post(HISTORY_RESOURCE_URI, data, headers)

          # Verify the request went through
          if resp.code == '403'
            raise resp.message
          else
            data = JSON.parse(resp.body)
            if data.size > 0
              start_index = data['result']['last_transaction']
              data['result']['sources'].each_with_index do |source, i|
                source['tracks'].each do |item|
                  history << Item.new(item)
                end
              end
            end
          end
        end
        return history
      end

    end
  end
end
