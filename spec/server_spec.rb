require 'spec_helper'
require 'topten/server'

module Topten
  describe Server do

    subject { Server.new(tag_store) }

    let(:tag_store) { double('tag_store', all: tags) }

    let(:tags) {
      # Generate an array where each tag occurs N times,
      # ie: "tag-1" occurs once, "tag-2" twice, etc.
      (1..20).inject([]) { |array, i|
        i.times { array << double("tag-#{i}", name: "tag-#{i}") }
        array
      }
    }

    it 'should return the top 10 most frequent tags' do
      expect(subject.topten).to eq (11..20).map{|i| {name: "tag-#{i}", frequency: i}}.reverse
    end
  end
end
