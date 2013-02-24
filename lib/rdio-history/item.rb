require 'json'
module Rdio
  module History
    class ItemParsingException < Exception
    end

    class Item
      attr_accessor :name, :time, :artist

      # We can extend this class to include whatever
      # data fields we'd like. For now, this data is sufficient
      def initialize(item)
        begin
          @name = item['track']['name']
          @time = item['time']
          @artist = item['track']['artist']
        rescue Exception => e
          raise ItemParsingException.new('Unexpected API format')
        end
      end

      def to_json(*a)
        return {
          'name' => @name,
          'time' => @time,
          'artist' => @artist
        }.to_json(*a)
      end
    end
  end
end
