require 'spec_helper'

RSpec.describe ContentfulLite::Link do
  let(:entry_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }
  subject { ContentfulLite::Link.new(entry_hash['fields']['bestFriend']) }

  describe '#attributes' do
    it { expect(subject.type).to eq :entry }
    it { expect(subject.id).to eq 'happycat' }

    context 'when converting from an Entry' do
      let(:entry) { ContentfulLite::Entry.new(entry_hash) }
      subject { ContentfulLite::Link.new(entry) }

      it { expect(subject.type).to eq :entry }
      it { expect(subject.id).to eq 'nyancat' }
    end

    context 'when converting from an Asset' do
      let(:asset_hash) { JSON.parse(File.read('fixtures/assets/nyancat.json')) }
      let(:asset) { ContentfulLite::Asset.new(asset_hash) }
      subject { ContentfulLite::Link.new(asset) }

      it { expect(subject.type).to eq :asset }
      it { expect(subject.id).to eq 'nyancat' }
    end
  end

  describe '#==' do
    let(:other_id) { 'happycat' }
    let(:other_type) { 'Entry' }
    let(:comparison) { ContentfulLite::Link.new( 'sys' => { 'linkType' => other_type, 'id' => other_id } ) }

    it { is_expected.to eq comparison }

    context 'when the id is different' do
      let(:other_id) { 'other' }

      it { is_expected.not_to eq comparison }
    end

    context 'when the type is different' do
      let(:other_id) { 'asset' }

      it { is_expected.not_to eq comparison }
    end

    context 'when the class is different' do
      let(:comparison) { OpenStruct.new(id: other_id, type: :entry) }

      it { is_expected.not_to eq comparison }
    end
  end

  describe '#as_json' do
    it { expect(subject.as_json).to eq(entry_hash['fields']['bestFriend']) }
  end
end
