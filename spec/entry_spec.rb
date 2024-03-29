require 'spec_helper'

RSpec.describe ContentfulLite::Entry do
  let(:entry_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }
  let(:instance) { ContentfulLite::Entry.new(entry_hash) }

  describe '#attributes' do
    it { expect(instance.content_type_id).to eq 'cat' }
    it { expect(instance.fields).to be_a Hash }
  end

  describe '#contentful_link' do
    subject { instance.contentful_link }

    it { is_expected.to eq 'https://app.contentful.com/spaces/cfexampleapi/entries/nyancat' }
  end

  describe 'Class methods' do
    describe '#field_reader' do
      let(:entry_class) do
        Class.new(ContentfulLite::Entry) do
          field_reader :name, localizable: true
          field_reader :color, :bestFriend, :friends
          field_reader :spayed, default: true
        end
      end
      subject { entry_class.new(entry_hash) }

      it { expect(subject.color).to eq 'rainbow' }
      it { expect(subject.bestFriend).to be_a ContentfulLite::Link }
      it { expect(subject.bestFriend.id).to eq 'happycat' }
      it { expect(subject.spayed).to eq true }

      context 'when the spayed field is nil' do
        before { entry_hash['fields']['spayed'] = nil }

        it 'falls back to the provided default' do
          expect(subject.spayed).to eq true
        end
      end

      context 'when the spayed field is set to false' do
        before { entry_hash['fields']['spayed'] = false }

        it { expect(subject.spayed).to eq false }
      end

      context 'with multiple locales' do
        let(:entry_hash) { JSON.parse(File.read('fixtures/entries/nyancat_with_locales.json')) }

        it { expect(subject.name).to eq 'Nyan Cat' }
        it { expect(subject.color).to eq 'rainbow' }
        it { expect(subject.color(locale: 'tlh')).to eq 'rainbow' }
        it { expect(subject.with_locale('tlh') { subject.color }).to eq 'rainbow' }
        it { expect(subject.bestFriend).to be_a ContentfulLite::Link }
        it { expect(subject.bestFriend.id).to eq 'happycat' }
        it { expect(subject.name(locale: 'tlh')).to eq 'Nyan vIghro\'' }
        it { expect(subject.with_locale('tlh') { subject.name }).to eq 'Nyan vIghro\'' }
      end

      context 'with an array of references' do
        let(:entry_hash) { JSON.parse(File.read('fixtures/entries/reference_array.json')) }

        it { expect(subject.friends.first).to be_a ContentfulLite::Link }
        it { expect(subject.friends.last).to be_a ContentfulLite::Link }
      end
    end
  end

  describe 'serializing' do
    subject { Marshal.load(Marshal.dump(instance)) }

    it { expect(subject.id).to eq(instance.id) }
    it { expect(subject.created_at).to eq(instance.created_at) }
    it { expect(subject.updated_at).to eq(instance.updated_at) }
    it { expect(subject.retrieved_at).to eq(instance.retrieved_at) }
    it { expect(subject.locale).to eq(instance.locale) }
    it { expect(subject.revision).to eq(instance.revision) }
    it { expect(subject.space_id).to eq(instance.space_id) }
    it { expect(subject.environment_id).to eq(instance.environment_id) }
    it { expect(subject.content_type_id).to eq(instance.content_type_id) }
    it { expect(subject.fields).to eq(instance.fields) }
  end
end
