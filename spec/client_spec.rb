require 'spec_helper'

RSpec.describe ContentfulLite::Client do
  let(:instance) { ContentfulLite::Client.new(space_id: 'cfexampleapi', access_token: 'b4c0n73n7fu1') }

  around(:each) do |example|
    VCR.use_cassette("client/#{cassette_name}") do
      example.run
    end
  end

  describe '#entries' do
    let(:cassette_name) { 'entries' }
    let(:query) { {} }
    subject do
      instance.entries(query)
    end

    it { is_expected.to be_a(Hash) }

    context 'when the query is invalid' do
      let(:cassette_name) { 'invalid_query' }
      let(:query) { { invalid_parameter: 'invalid_value' } }

      it { expect { subject }.to raise_error(ContentfulLite::Client::RequestError) }
    end
  end
end
