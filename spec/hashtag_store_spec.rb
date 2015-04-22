require 'spec_helper'
require 'topten/hashtag_store'

module Topten

  shared_context 'old tag' do
    let (:tag_date) { 
      DateTime.parse("2015-04-22 13:21:59 -0400")
    }
  end

  shared_context 'young tag' do
    let (:tag_date) { 
      DateTime.parse("2015-04-22 13:22:00 -0400")
    }
  end

  describe HashtagStore do
    let(:hashtag) { Hashtag.new('name', tag_date) } 

    before (:each) do
      allow(Time).to receive(:now){ 
        DateTime.parse("2015-04-22 13:23:00 -0400").to_time
      }
    end

    describe '#add' do
      context 'when tag is older than 60 seconds' do
        include_context 'old tag'
        it 'should expire the tag' do
          expect(subject.add(hashtag).instance_variable_get(:@tags)).to eq []
        end
      end

      context 'when tag is 60 seconds old or younger' do
        include_context 'young tag'
        it 'should keep the tag' do
          expect(subject.add(hashtag).instance_variable_get(:@tags)).to eq(
            [ hashtag ]
          )
        end
      end
    end

    describe '#all' do
      subject { 
        HashtagStore.new.tap { |store|
          store.instance_variable_set(:@tags, [hashtag])
        }
      }

      context 'when tags are older than 60 seconds' do
        include_context 'old tag'
        it 'should return no tags' do
          expect(subject.all).to eq []
        end

        it 'should duplicate the array of tags' do
          expect(subject.all).not_to be subject.instance_variable_get(:@tags)
        end
      end

      context 'when tags are younger than 60 seconds' do
        include_context 'young tag'
        it 'should return tags' do
          expect(subject.all).to eq [hashtag]
        end
      end
    end

  end
end

