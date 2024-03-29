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

    it 'should properly serialize the nested mutually-related entries' do
      friend = instance[5].as_json['fields']['bestFriend']
      expect(friend['sys']['type']).to eq('Entry')
      expect(friend['sys']['id']).to eq('nyancat')
      expect(friend['fields']['bestFriend']['sys']['type']).to eq('Link')
      expect(friend['fields']['bestFriend']['sys']['id']).to eq('happycat')
    end

    context 'with an array of references' do
      let(:response) { JSON.parse(File.read('fixtures/entries/all_with_reference_array.json')) }

      it 'should solve the linked assets' do
        expect(instance[4].fields['images'].first).to be_an ContentfulLite::Asset
        expect(instance[4].fields['images'].first.url).to eq '//images.ctfassets.net/cfexampleapi/4hlteQAXS8iS0YCMU6QMWg/2a4d826144f014109364ccf5c891d2dd/jake.png'
      end

      it 'should solve the nested mutually-related entries' do
        expect(instance[5].fields['friends'].first).to be_an ContentfulLite::Entry
        expect(instance[5].fields['friends'].first.fields['friends'].first).to eq instance[5]
      end

      it 'should properly serialize the nested mutually-related entries' do
        friend = instance[5].as_json['fields']['friends'].first
        expect(friend['sys']['type']).to eq('Entry')
        expect(friend['sys']['id']).to eq('nyancat')
        expect(friend['fields']['friends'].first['sys']['type']).to eq('Link')
        expect(friend['fields']['friends'].first['sys']['id']).to eq('happycat')
      end
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

    context 'when include nesting is not enough' do
      let(:response) { JSON.parse(File.read('fixtures/entries/all_without_includes.json')) }

      it { expect(instance.first).to be_an ContentfulLite::Entry }
      it { expect(instance.last).to be_an ContentfulLite::Entry }
      it { expect(instance.sample).to be_an ContentfulLite::Entry }

      it 'should create links for the assets' do
        expect(instance[4].fields['image']).to be_an ContentfulLite::Link
        expect(instance[4].fields['image'].type).to eq :asset
        expect(instance[4].fields['image'].id).to eq 'jake'
      end

      it 'should solve the nested mutually-related entries' do
        expect(instance[5].fields['bestFriend']).to be_an ContentfulLite::Link
        expect(instance[5].fields['bestFriend'].type).to eq :entry
        expect(instance[5].fields['bestFriend'].id).to eq 'nyancat'
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
