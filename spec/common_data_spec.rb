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
end
