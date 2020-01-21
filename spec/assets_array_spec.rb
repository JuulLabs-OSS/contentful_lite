require 'spec_helper'

RSpec.describe ContentfulLite::AssetsArray do
  let(:response) { JSON.parse(File.read('fixtures/assets/all.json')) }
  let(:instance) { ContentfulLite::AssetsArray.new(response) }

  describe 'should create an array of assets' do
    it { expect(instance.first).to be_an ContentfulLite::Asset }
    it { expect(instance.last).to be_an ContentfulLite::Asset }
    it { expect(instance.sample).to be_an ContentfulLite::Asset }
  end
end
