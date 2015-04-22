require 'spec_helper'
require 'json'
require 'topten/consumer'

module Topten
  describe Consumer do
    subject { Consumer.new(tag_store) }
    let(:tag_store) { double('tag_store') }

    describe '#run' do

      let (:created_at) { 'Wed Apr 22 16:19:38 +0000 2015' }

      before :each do
        allow(TwitterStream).to receive(:new) {
          double('twitter_stream').tap do |ts|
            allow(ts).to receive(:run).and_yield(msg)
          end
        } 
      end

      context 'when message has a date' do
        let(:msg) { 
          {
            created_at: created_at,
            entities: {hashtags: [{text: 'hashtag'}]}
          }.to_json
        }        

        it 'should save a tag' do
          expect(tag_store).to receive(:add).with(
            Hashtag.new(
              DateTime.parse(created_at),
              'hashtag'))
          subject.run
        end
      end 

      context 'when message has no date' do
        let(:msg) { {}.to_json }
        it 'should not save a tag' do
          subject.run
        end
      end

    end

  end

end
