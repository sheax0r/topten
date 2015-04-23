require 'spec_helper'
require 'topten/twitter_stream'

module Topten
  describe TwitterStream do
    describe '#run' do
      let(:oauth_yml) { double 'oauth.yml' }
      let(:credentials) { double 'credentials' }
      let(:http) { double('http') }
      let(:request) { double('request') }
      let(:response) { double('response', code: '200') }
      let(:chunk) { 'chunk' }

      before :each do
        allow(File).to receive(:read).with('oauth.yml') { oauth_yml }
        allow(YAML).to receive(:load).with(oauth_yml) { credentials }
        allow(Net::HTTP).to receive(:new).with('stream.twitter.com', 443) { http }
        allow(http).to receive(:use_ssl=).with(true)
        allow(http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
        allow(subject).to receive(:sign_request).with(request, credentials)
        allow(http).to receive(:request).with(request) { |_, &block| block.call(response) }
        allow(response).to receive(:read_body){ |_, &block| block.call(chunk) }
        allow(Net::HTTP::Get).to receive(:new).with('/1.1/statuses/sample.json?delimited=length') { request }
        # Three messages.
        allow(subject).to receive(:next_message).and_return(
          'message1', 
          'message2',
          nil)
      end

      it 'should parse all messages from the current chunk' do
        expect { |b|
          subject.run(&b) 
        }.to yield_successive_args('message1', 'message2')
      end
    end

    describe '#next_message' do

      let(:array) { buffer.split(//) }

      def next_message
        subject.next_message(array)
      end

      shared_examples 'incomplete message' do
        it 'returns nil' do
          expect(next_message).to eq nil
          expect(array).to eq buffer.split(//)
        end
      end

      context 'when there is no line break' do
        let(:buffer) { '5' }
        it_behaves_like 'incomplete message'
      end

      context 'when the content is not as long as the length header' do
        let(:buffer) { "5\r\nhell" }
        it_behaves_like 'incomplete message'
      end

      context 'when there is a complete message' do
        let(:buffer) { "5\r\nhello" }
        it 'returns a message' do 
          expect(next_message).to eq "hello"
          expect(array).to eq []
        end
      end

      context 'when there is data following the message' do
        let(:buffer) { "5\r\nhello\r\n5\r\nagain" }
        it 'leaves the data following the message alone' do 
          expect(next_message).to eq "hello"
          expect(array).to eq "\r\n5\r\nagain".split(//)
        end
      end

      context 'when there are newlines at the start of the chunk' do
        let(:buffer) { "\r\n\r\n5\r\nhello" }
        it 'trims the newlines and parses the message' do 
          expect(next_message).to eq "hello"
          expect(array).to eq []
        end
      end
    end
  end
end
