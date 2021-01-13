require 'spec_helper'

RSpec.describe ContentfulLite::CommonData do
  let(:klass) { Class.new.include(described_class) }
  let(:instance) { klass.new(raw_hash) }

  describe '#attributes' do
    context 'with an entry' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }

      it { expect(instance.id).to eq 'nyancat' }
      it { expect(instance.created_at).to eq DateTime.new(2013, 6, 27, 22, 46, 19.513) }
      it { expect(instance.updated_at).to eq DateTime.new(2013, 9, 4, 9, 19, 39.027) }
      it { expect(instance.locale).to eq 'en-US' }
      it { expect(instance.revision).to eq 5 }
      it { expect(instance.space_id).to eq 'cfexampleapi' }
      it { expect(instance.environment_id).to eq 'master' }
      it { expect(instance.retrieved_at).to be_a DateTime }
    end
  end

  describe '#attributes' do
    context 'with an asset' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/assets/nyancat.json')) }

      it { expect(instance.id).to eq 'nyancat' }
      it { expect(instance.created_at).to eq DateTime.new(2013, 9, 2, 14, 56, 34.240) }
      it { expect(instance.updated_at).to eq DateTime.new(2013, 9, 2, 14, 56, 34.240) }
      it { expect(instance.locale).to eq 'en-US' }
      it { expect(instance.revision).to eq 1 }
      it { expect(instance.space_id).to eq 'cfexampleapi' }
      it { expect(instance.environment_id).to eq 'master' }
      it { expect(instance.retrieved_at).to be_a DateTime }
    end
  end

  describe '#fields' do
    subject { instance.fields['name'] }

    context 'for a single locale entry' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }

      it { is_expected.to eq 'Nyan Cat' }

      context 'when specific locale is requested' do
        subject { instance.fields(locale: 'tlh')['name'] }

        it { is_expected.to eq nil }
      end
    end

    context 'for a multiple locale entry' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat_with_locales.json')) }

      it { is_expected.to eq 'Nyan Cat' }

      context 'when specific locale is requested' do
        subject { instance.fields(locale: 'tlh')['name'] }

        it { is_expected.to eq "Nyan vIghro'" }
      end
    end
  end

  describe '#with_locale' do
    subject { instance.with_locale('tlh') { instance.fields['name'] } }

    context 'for a multiple locale entry' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat_with_locales.json')) }

      it { is_expected.to eq "Nyan vIghro'" }
    end
  end

  describe '#to_link' do
    let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }

    subject { instance.to_link }

    it { expect(subject.id).to eq 'nyancat' }
    it { expect(subject.type).to eq :entry }

    context 'with an asset' do
      let(:raw_hash) { JSON.parse(File.read('fixtures/assets/nyancat.json')) }

      it { expect(subject.id).to eq 'nyancat' }
      it { expect(subject.type).to eq :asset }
    end
  end

  describe '#as_json' do
    let(:raw_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }

    subject { instance.as_json }

    it { is_expected.to eq(raw_hash.symbolize_keys) }
  end
end
