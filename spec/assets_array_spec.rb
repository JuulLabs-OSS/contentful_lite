require 'spec_helper'

RSpec.describe ContentfulLite::AssetsArray do
  let(:response) { JSON.parse(File.read('fixtures/assets/all.json')) }
  let(:instance) { ContentfulLite::AssetsArray.new(response) }

  describe 'should create an array of assets' do
    it { expect(instance.first).to be_an ContentfulLite::Asset }
    it { expect(instance.last).to be_an ContentfulLite::Asset }
    it { expect(instance.sample).to be_an ContentfulLite::Asset }
  end

  describe 'serializing' do
    subject { Marshal.load(Marshal.dump(instance)) }

    it { expect(subject.first.id).to eq(instance.first.id) }
    it { expect(subject.first.file_name).to eq(instance.first.file_name) }
    it { expect(subject.last.file_details).to eq(instance.last.file_details) }
    it { expect(subject.last.id).to eq(instance.last.id) }
    it { expect(subject.last.file_name).to eq(instance.last.file_name) }
    it { expect(subject.last.file_details).to eq(instance.last.file_details) }
  end
end
