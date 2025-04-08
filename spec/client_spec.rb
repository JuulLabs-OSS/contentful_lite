require 'spec_helper'

RSpec.describe ContentfulLite::Client do
  let(:instance) { ContentfulLite::Client.new(space_id: 'cfexampleapi', access_token: 'b4c0n73n7fu1') }

  around(:each) do |example|
    if defined?(cassette_name)
      VCR.use_cassette("client/#{cassette_name}") do
        example.run
      end
    else
      example.run
    end
  end

  describe '#entries' do
    let(:cassette_name) { 'entries' }
    let(:query) { {} }
    subject do
      instance.entries(query)
    end

    it { is_expected.to be_a(ContentfulLite::EntriesArray) }

    context 'when the query is invalid' do
      let(:cassette_name) { 'invalid_query' }
      let(:query) { { invalid_parameter: 'invalid_value' } }

      it { expect { subject }.to raise_error(ContentfulLite::Client::RequestError, "InvalidQuery: The query you sent was invalid. Probably a filter or ordering specification is not applicable to the type of a field.") }
    end

    context 'when the query has an array parameter' do
      let(:cassette_name) { 'array_parameter' }
      let(:query) { { 'sys.id[in]': ['nyancat', 'happycat'] } }

      it { is_expected.to be_a(ContentfulLite::EntriesArray) }
      it { expect(subject.size).to eq 2 }
    end

    context 'response JSON is invalid' do
      before do
        stub_request(:get, %r{contentful.com/spaces/.*/entries}).
          to_return(body: "connection failure")
      end

      it do
        expect { subject }.to raise_error(
          ContentfulLite::Client::RequestError,
          "Invalid Contentful Response: connection failure"
        )
      end
    end
  end

  describe '#entry' do
    let(:cassette_name) { 'entry' }
    let(:query) { {} }
    let(:entry_id) { 'nyancat' }
    subject do
      instance.entry(entry_id, query)
    end

    it { is_expected.to be_a(ContentfulLite::Entry) }

    context 'when the query is invalid' do
      let(:cassette_name) { 'entry_invalid_query' }
      let(:query) { { locale: 'invalid_value' } }

      it { expect { subject }.to raise_error(ContentfulLite::Client::RequestError, "BadRequest: Unknown locale: invalid_value") }
    end

    context 'when the id is not found' do
      let(:cassette_name) { 'entry_missings_id' }
      let(:entry_id) { 'invalidcat' }

      it { expect { subject }.to raise_error(ContentfulLite::Client::NotFoundError, "NotFound: The resource could not be found.") }
    end
  end

  describe '#assets' do
    let(:cassette_name) { 'assets' }
    let(:query) { {} }
    subject do
      instance.assets(query)
    end

    it { is_expected.to be_a(ContentfulLite::AssetsArray) }

    context 'when the query is invalid' do
      let(:cassette_name) { 'assets_invalid_query' }
      let(:query) { { invalid_parameter: 'invalid_value' } }

      it { expect { subject }.to raise_error(ContentfulLite::Client::RequestError, "InvalidQuery: The query you sent was invalid. Probably a filter or ordering specification is not applicable to the type of a field.") }
    end
  end

  describe '#asset' do
    let(:cassette_name) { 'asset' }
    let(:query) { {} }
    let(:asset_id) { 'nyancat' }
    subject do
      instance.asset(asset_id, query)
    end

    it { is_expected.to be_a(ContentfulLite::Asset) }

    context 'when the query is invalid' do
      let(:cassette_name) { 'asset_invalid_query' }
      let(:query) { { locale: 'invalid_value' } }

      it { expect { subject }.to raise_error(ContentfulLite::Client::RequestError, "BadRequest: Unknown locale: invalid_value") }
    end

    context 'when the id is not found' do
      let(:cassette_name) { 'asset_missings_id' }
      let(:asset_id) { 'invalidcat' }

      it { expect { subject }.to raise_error(ContentfulLite::Client::NotFoundError, "NotFound: The resource could not be found.") }
    end
  end

  describe '#build_resource' do
    let(:fixture) { 'entries/nyancat' }
    let(:hash) { JSON.parse(File.read("fixtures/#{fixture}.json")) }
    subject do
      instance.build_resource(hash)
    end

    it { is_expected.to be_a(ContentfulLite::Entry) }

    context 'when the resource is an asset' do
      let(:fixture) { 'assets/nyancat' }

      it { is_expected.to be_a(ContentfulLite::Asset) }
    end

    context 'when the resource is a DeletedEntry' do
      let(:fixture) { 'entries/deleted_entry' }

      it { is_expected.to be_a(ContentfulLite::DeletedEntry) }
    end
  end
end
