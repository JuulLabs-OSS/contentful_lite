require 'spec_helper'

RSpec.describe ContentfulLite::DeletedEntry do
  let(:entry_hash) { JSON.parse(File.read('fixtures/entries/deleted_entry.json')) }
  let(:instance) { ContentfulLite::DeletedEntry.new(entry_hash) }

  describe '#attributes' do
    it { expect(instance.content_type_id).to eq 'cat' }
    it { expect(instance.id).to eq 'deletedcat' }
  end

  describe '#contentful_link' do
    subject { instance.contentful_link }

    it { expect { subject }.to raise_error NotImplementedError }
  end

  describe 'serializing' do
    subject { Marshal.load(Marshal.dump(instance)) }

    it { expect(subject.id).to eq(instance.id) }
    it { expect(subject.created_at).to eq(instance.created_at) }
    it { expect(subject.updated_at).to eq(instance.updated_at) }
    it { expect(subject.retrieved_at).to eq(instance.retrieved_at) }
    it { expect(subject.revision).to eq(instance.revision) }
    it { expect(subject.space_id).to eq(instance.space_id) }
    it { expect(subject.environment_id).to eq(instance.environment_id) }
    it { expect(subject.content_type_id).to eq(instance.content_type_id) }
  end
end
