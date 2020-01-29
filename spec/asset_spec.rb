require 'spec_helper'

RSpec.describe ContentfulLite::Asset do
  let(:entry_hash) { JSON.parse(File.read('fixtures/assets/nyancat.json')) }
  let(:instance) { ContentfulLite::Asset.new(entry_hash) }

  describe '#attributes' do
    it { expect(instance.title).to eq 'Nyan Cat' }
    it { expect(instance.description).to eq '' }
    it { expect(instance.url).to eq '//images.ctfassets.net/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png' }
    it { expect(instance.file_name).to eq 'Nyan_cat_250px_frame.png' }
    it { expect(instance.content_type).to eq 'image/png' }
  end

  describe '#contentful_link' do
    subject { instance.contentful_link }

    it { is_expected.to eq 'https://app.contentful.com/spaces/cfexampleapi/assets/nyancat' }
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
    it { expect(subject.title).to eq(instance.title) }
    it { expect(subject.description).to eq(instance.description) }
    it { expect(subject.file_name).to eq(instance.file_name) }
    it { expect(subject.content_type).to eq(instance.content_type) }
    it { expect(subject.url).to eq(instance.url) }
    it { expect(subject.file_details).to eq(instance.file_details) }
  end
end
