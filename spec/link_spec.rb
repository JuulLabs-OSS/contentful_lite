require 'spec_helper'

RSpec.describe ContentfulLite::Link do
  let(:entry_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }
  subject { ContentfulLite::Link.new(entry_hash['fields']['bestFriend']) }

  describe '#attributes' do
    it { expect(subject.type).to eq :entry }
    it { expect(subject.id).to eq 'happycat' }
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
end
