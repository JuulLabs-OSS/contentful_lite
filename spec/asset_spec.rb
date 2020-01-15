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
end
