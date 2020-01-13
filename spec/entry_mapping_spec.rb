require 'spec_helper'

RSpec.describe ContentfulLite::EntryMapping do
  let(:base_class) { Class.new.include(described_class) }
  let!(:inherited_class) { Class.new(base_class) { content_type_id 'inherited_type' } }

  describe '#get_class' do
    subject { base_class.get_class(content_type) }

    context 'for an existing content_type_id' do
      let(:content_type) { 'inherited_type' }
      it { is_expected.to eq(inherited_class) }
    end

    context 'for an invalid content_type_id' do
      let(:content_type) { 'invalid_type' }
      it { is_expected.to eq(base_class) }
    end
  end
end
