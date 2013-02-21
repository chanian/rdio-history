require 'json'
require 'helper'
require 'rdio-history/fetcher'

describe Rdio::History::Fetcher do

  before :each do
    session = {
      :user_id => 123,
      :authorization_key => 123,
      :authorization_cookie => 123
    }
    @fetcher = Rdio::History::Fetcher.new(session)
  end

  describe '#fetch' do
    context 'on a valid http request' do
      before :each do
        # Default mock for any output HTTP Post
        @mock_response = {}
        @mock_response.stub(:code) { 200 }
        @mock_response.stub(:body) { "{}" }

        Net::HTTP.any_instance.stub(:post) { @mock_response }
      end

      it 'should make an HTTP POST' do
        Net::HTTP.any_instance.should_receive(:post)
        @fetcher.fetch
      end

      it 'should send an auth cookie header' do
        Net::HTTP.any_instance.should_receive(:post) { |uri, data, headers|
          expect(headers['Cookie']).not_to be_nil
          @mock_response
        }
        @fetcher.fetch
      end

      it 'should send an authorization key data param' do
        Net::HTTP.any_instance.should_receive(:post) { |uri, data, headers|
          expect(data).to match /_authorization_key=/
          @mock_response
        }
        @fetcher.fetch
      end

      it 'should by default send a single HTTP post' do
        Net::HTTP.any_instance.should_receive(:post).exactly(1).times
        @fetcher.fetch
      end

      it 'should return an array' do
        results = @fetcher.fetch
        expect(results).to be_a_kind_of(Array)
      end

      context 'when there are results' do
        before :each do
          @mock_response = {}
          @mock_response.stub(:code) { 200 }
          @mock_response.stub(:body) { json_fixture }
          Net::HTTP.any_instance.stub(:post) {
            @mock_response
          }
        end

        it 'should return history items' do
          entry = @fetcher.fetch.first
          expect(entry).to_not be_nil
          expect(entry.name).to eq('Crystalized')
          expect(entry.artist).to eq('The XX')
          expect(entry.time).to eq(12345)
        end

        it 'should enumerate and return all tracks' do
          entries = @fetcher.fetch
          entry = entries[1]
          expect(entries.size).to eq(3)
          expect(entry).to_not be_nil
          expect(entry.name).to eq('Intro')
          expect(entry.artist).to eq('The XX')
          expect(entry.time).to eq(54321)
        end

        it 'should flatten all sources/track to a single array' do
          entries = @fetcher.fetch
          entry = entries.last
          expect(entry).to_not be_nil
          expect(entry.name).to eq('Infinite Love Without Fulfilment')
          expect(entry.artist).to eq('Grimes')
          expect(entry.time).to eq(12345)
        end

        context 'when sending multiple requests with valid cursor changes' do
          it 'should send updated cursor according to last_trasaction from API' do
            @fetcher.fetch
            Net::HTTP.any_instance.stub(:post) { |uri, data, headers|
              params = data.split('&').inject({}) { |res, c| (res[c.split('=').first] = c.split('=').last); res }
              expect(params['start']).to eq('20')
              @mock_response
            }
            # second fetch relies on the last_transaction id from the previous request
            @fetcher.fetch
          end
        end
      end
    end
  end
end
