require 'spec_helper'
require 'topten/hashtag'

module Topten
  describe Hashtag do
    let (:name) { 'name' }
    let (:date) { 'date' }
    subject { Hashtag.new(name, date) }

    describe '#==' do
      it 'should be equal to an identical hashtag' do
        expect(subject).to eq Hashtag.new(name, date)
      end      

      it 'should not be equal to a hashtag with a different name' do
        expect(subject).not_to eq Hashtag.new('other-name', date)
      end

      it 'should not be equal to a hashtag with a different date' do
        expect(subject).not_to eq Hashtag.new(name, 'other-date')
      end

      it 'should not be equal to something other than a hashtag' do
        expect(subject).not_to eq Object.new
      end
    end

    describe '#hash' do
      it 'should have the same hash as an identical hashtag' do
        expect(subject.hash).to eq Hashtag.new(name, date).hash
      end      

      it 'should have a different hash from a hashtag with a different name' do
        expect(subject.hash).not_to eq Hashtag.new('other-name', date).hash
      end

      it 'should have a different hash from a hashtag with a different date' do
        expect(subject.hash).not_to eq Hashtag.new(name, 'other-date').hash
      end
    end
  end
end
