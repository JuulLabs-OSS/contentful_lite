require 'spec_helper'

RSpec.describe ContentfulLite::EntriesArray do
  let(:response) { JSON.parse(File.read('fixtures/entries/all.json')) }
  let(:instance) { ContentfulLite::EntriesArray.new(response) }

  describe 'should create an array of entries' do
    it { expect(instance.first).to be_an ContentfulLite::Entry }
    it { expect(instance.last).to be_an ContentfulLite::Entry }
    it { expect(instance.sample).to be_an ContentfulLite::Entry }

    it 'should solve the linked assets' do
      expect(instance[4].fields['image']).to be_an ContentfulLite::Asset
      expect(instance[4].fields['image'].url).to eq '//images.ctfassets.net/cfexampleapi/4hlteQAXS8iS0YCMU6QMWg/2a4d826144f014109364ccf5c891d2dd/jake.png'
    end

    it 'should solve the nested mutually-related entries' do
      expect(instance[5].fields['bestFriend']).to be_an ContentfulLite::Entry
      expect(instance[5].fields['bestFriend'].fields['bestFriend']).to eq instance[5]
    end

    context 'with multiple locales' do
      let(:response) { JSON.parse(File.read('fixtures/entries/all_with_locales.json')) }

      it { expect(instance[5].fields(locale: 'tlh')['name']).to eq("Quch vIghro'") }

      it 'should solve the linked assets' do
        expect(instance[4].fields['image']).to be_an ContentfulLite::Asset
        expect(instance[4].fields['image'].url).to eq '//images.ctfassets.net/cfexampleapi/4hlteQAXS8iS0YCMU6QMWg/2a4d826144f014109364ccf5c891d2dd/jake.png'
      end

      it 'should solve the nested mutually-related entries' do
        expect(instance[5].fields['bestFriend']).to be_an ContentfulLite::Entry
        expect(instance[5].fields['bestFriend'].fields['bestFriend']).to eq instance[5]
      end
    end

    describe 'serializing' do
      subject { Marshal.load(Marshal.dump(instance)) }

      it { expect(subject.first.id).to eq(instance.first.id) }
      it { expect(subject.first.fields).to eq(instance.first.fields) }
      it { expect(subject.last.id).to eq(instance.last.id) }
      it { expect(subject.last.fields).to eq(instance.last.fields) }

      it 'should solve the nested mutually-related entries' do
        expect(subject[5].fields['bestFriend']).to be_an ContentfulLite::Entry
        expect(subject[5].fields['bestFriend'].fields['bestFriend']).to eq subject[5]
      end
    end
  end
end
