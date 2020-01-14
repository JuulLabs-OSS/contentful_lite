require 'spec_helper'

RSpec.describe ContentfulLite::Entry do
  let(:entry_hash) { JSON.parse(File.read('fixtures/entries/nyancat.json')) }
  let(:instance) { ContentfulLite::Entry.new(entry_hash, []) }

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
      let(:entry_class) { Class.new(ContentfulLite::Entry) { field_reader :color } }
      subject { entry_class.new(entry_hash, []).color }

      it { is_expected.to eq 'rainbow' }
    end
  end
end
