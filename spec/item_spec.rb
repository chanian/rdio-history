require 'rdio-history/item'

describe Rdio::History::Item do
  before :each do
    @track = 'Music Is My Hot Hot Sex'
    @artist = 'CSS'
    @timestamp = 12345
    @api_item = {
      'track' => {
        'name' => @track,
        'artist' => @artist
      },
      'time' => @timestamp
    }
  end

  describe '#initialize' do
    it 'should raise a parsing exception if encountering unexpected format' do
      @api_item['track'] = nil
      lambda { item = Rdio::History::Item.new(@api_item) }.should raise_exception(Rdio::History::ItemParsingException)
    end

    it 'should properly parse an API response item' do
      item = Rdio::History::Item.new(@api_item)

      expect(item.name).to eq(@track)
      expect(item.artist).to eq(@artist)
      expect(item.time).to eq(@timestamp)
    end
  end
end