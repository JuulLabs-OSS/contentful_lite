require 'spec_helper'

RSpec.describe ContentfulLite::BaseArray do
  let(:instance) { ContentfulLite::BaseArray.new(response) }

  describe '#attributes' do
    context 'for an array of assets' do
      let(:response) { JSON.parse(File.read('fixtures/assets/all.json')) }

      it { expect(instance.total).to eq 4 }
      it { expect(instance.skip).to eq 0 }
      it { expect(instance.limit).to eq 100 }
    end
  end

  describe '#attributes' do
    context 'for an array of entries' do
      let(:response) { JSON.parse(File.read('fixtures/entries/all.json')) }

      it { expect(instance.total).to eq 10 }
      it { expect(instance.skip).to eq 0 }
      it { expect(instance.limit).to eq 100 }
    end
  end
end
