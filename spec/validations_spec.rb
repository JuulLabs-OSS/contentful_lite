require 'spec_helper'

RSpec.describe ContentfulLite::Validations::Entry do
  def create_validable_model(validation_method, options)
    klass = Class.new do
      include ContentfulLite::Validations::Entry
      attr_reader :fake_field
      attr_accessor :locale

      send(validation_method, :fake_field, options)

      def initialize(value)
        @fake_field = value
        @locale = :en
      end

      def with_locale(locale)
        @locale = locale unless locale.nil?
        yield
      ensure
        @locale = :en
      end
    end
    allow(klass).to receive(:model_name).and_return ActiveModel::Name.new(klass, nil, 'FakeClasss')
    allow(klass).to receive(:human_attribute_name).and_return 'fake_field'
    klass
  end

  shared_context 'multiple locales support' do
    before do # Mock Entry localization, as it is part of the entry class and not the validations module
      allow(fake_model).to receive(:locales).and_return(%i[en es])
      allow(fake_model).to receive(:fake_field) { value[fake_model.locale] }
    end
  end

  let(:model_class) { create_validable_model(:validates_presence_of, {}) }
  let(:fake_model) { model_class.new(value) }

  describe '#valid?' do
    include_context 'multiple locales support'
    let(:value) { { en: 'valid', es: 'valid' } }
    subject { fake_model.valid?(locale: :es) }

    it { is_expected.to be_truthy }

    context 'when the other locale has invalid content' do
      let(:value) { { en: nil, es: 'valid' } }
      it { is_expected.to be_truthy }
    end

    context 'when that locale has invalid content' do
      let(:value) { { en: 'valid', es: nil } }
      it { is_expected.to be_falsey }
    end

    context 'when both locales have invalid content' do
      let(:value) { { en: nil, es: nil } }
      it { is_expected.to be_falsey }
    end
  end

  describe '#valid_for_all_locales?' do
    include_context 'multiple locales support'
    let(:value) { { en: 'valid', es: 'valid' } }
    subject { fake_model.valid_for_all_locales? }

    it { is_expected.to be_truthy }

    context 'when first locale has invalid content' do
      let(:value) { { en: nil, es: 'valid' } }
      it { is_expected.to be_falsey }
    end

    context 'when second locale has invalid content' do
      let(:value) { { en: 'valid', es: nil } }
      it { is_expected.to be_falsey }
    end

    context 'when both locales have invalid content' do
      let(:value) { { en: nil, es: nil } }
      it { is_expected.to be_falsey }
    end
  end

  describe '#errors' do
    include_context 'multiple locales support'
    let(:value) { { en: 'valid', es: 'valid' } }
    subject(:en) { fake_model.tap(&:valid_for_all_locales?).errors(locale: :en)[:fake_field] }
    subject(:es) { fake_model.tap(&:valid_for_all_locales?).errors(locale: :es)[:fake_field] }

    it { expect(en).to be_empty }
    it { expect(es).to be_empty }

    context 'when first locale has invalid content' do
      let(:value) { { en: nil, es: 'valid' } }
      it { expect(en).to eq ["can't be blank"] }
      it { expect(es).to be_empty }
    end

    context 'when second locale has invalid content' do
      let(:value) { { en: 'valid', es: nil } }

      it { expect(en).to be_empty }
      it { expect(es).to eq ["can't be blank"] }
    end

    context 'when both locales have invalid content' do
      let(:value) { { en: nil, es: nil } }

      it { expect(en).to eq ["can't be blank"] }
      it { expect(es).to eq ["can't be blank"] }
    end
  end

  describe '.validates_included_asset' do
    subject { fake_model.tap(&:valid?).errors[:fake_field] }

    let(:asset) { ContentfulLite::Asset.new(JSON.parse(File.read('fixtures/assets/nyancat.json'))) }
    let(:model_class) do
      create_validable_model(:validates_included_asset, options)
    end
    let(:value) { nil }
    let(:options) { {} }

    describe 'allow_blank' do
      context 'when value is nil and blank is allowed' do
        let(:options) { { allow_blank: true } }

        it { is_expected.to be_empty }
      end

      context 'when value is nil and blank is not allowed' do
        let(:options) { { allow_blank: false } }

        it { is_expected.to eq ['value is blank'] }
      end

      context 'when value is [] and blank is allowed' do
        let(:options) { { allow_blank: true } }
        let(:value) { [] }

        it { is_expected.to be_empty }
      end

      context 'when value is [] and blank is not allowed' do
        let(:options) { { allow_blank: false } }
        let(:value) { [] }

        it { is_expected.to eq ['value is blank'] }
      end

      context 'when value exists and blank is not allowed' do
        let(:value) { asset }

        it { is_expected.to be_empty }
      end
    end

    describe 'array' do
      context 'when value is not an array as expected' do
        let(:value) { asset }
        it { is_expected.to be_empty }
      end

      context 'when value is an array as expected' do
        let(:value) { [asset] }
        let(:options) { { array: true } }
        it { is_expected.to be_empty }
      end

      context 'when value is not an asset or array' do
        let(:value) { Object.new }
        it { is_expected.to eq ['value is not a published asset'] }
      end

      context 'when value is an array with other objects' do
        let(:value) { [asset, Object.new] }
        let(:options) { { array: true } }
        it { is_expected.to eq ['value[1] is not a published asset'] }
      end

      context 'when expects and array and has single value' do
        let(:value) { asset }
        let(:options) { { array: true } }
        it { is_expected.to eq ['value is not an array'] }
      end

      context 'when expects a single value and has an array' do
        let(:value) { [asset] }
        it { is_expected.to eq ['value is not a published asset'] }
      end
    end

    describe 'type' do
      context 'when value is an image as expected' do
        let(:options) { { type: :image } }
        let(:value) { asset }
        it { is_expected.to be_empty }
      end

      context 'when value is an image and expects a video' do
        let(:options) { { type: :video } }
        let(:value) { asset }
        it { is_expected.to eq ['value has an invalid asset type. Expecting video'] }
      end

      context 'when values array has an image and expects only videos' do
        let(:options) { { type: :video, array: true } }
        let(:value) { [asset] }
        it { is_expected.to eq ['value[0] has an invalid asset type. Expecting video'] }
      end
    end
  end

  describe '.validates_included_entry' do
    subject { fake_model.tap(&:valid?).errors[:fake_field] }

    let(:entry) { ContentfulLite::Entry.new(JSON.parse(File.read('fixtures/entries/nyancat.json'))) }
    let(:model_class) do
      create_validable_model(:validates_included_entry, options)
    end
    let(:value) { nil }
    let(:options) { {} }

    describe 'allow_blank' do
      context 'when value is nil and blank is allowed' do
        let(:options) { { allow_blank: true } }

        it { is_expected.to be_empty }
      end

      context 'when value is nil and blank is not allowed' do
        let(:options) { { allow_blank: false } }

        it { is_expected.to eq ['value is blank'] }
      end

      context 'when value is [] and blank is allowed' do
        let(:options) { { allow_blank: true } }
        let(:value) { [] }

        it { is_expected.to be_empty }
      end

      context 'when value is [] and blank is not allowed' do
        let(:options) { { allow_blank: false } }
        let(:value) { [] }

        it { is_expected.to eq ['value is blank'] }
      end

      context 'when value exists and blank is not allowed' do
        let(:value) { entry }

        it { is_expected.to be_empty }
      end
    end

    describe 'array' do
      context 'when value is not an array as expected' do
        let(:value) { entry }
        it { is_expected.to be_empty }
      end

      context 'when value is an array as expected' do
        let(:value) { [entry] }
        let(:options) { { array: true } }
        it { is_expected.to be_empty }
      end

      context 'when value is not an entry or array' do
        let(:value) { Object.new }
        it { is_expected.to eq ['value is not a published entry'] }
      end

      context 'when value is an array with other objects' do
        let(:value) { [entry, Object.new] }
        let(:options) { { array: true } }
        it { is_expected.to eq ['value[1] is not a published entry'] }
      end

      context 'when expects and array and has single value' do
        let(:value) { entry }
        let(:options) { { array: true } }
        it { is_expected.to eq ['value is not an array'] }
      end

      context 'when expects a single value and has an array' do
        let(:value) { [entry] }
        it { is_expected.to eq ['value is not a published entry'] }
      end
    end

    describe 'invalid child' do
      before { expect(entry).to receive(:valid?).and_return false }

      context 'when the entry is invalid' do
        let(:value) { entry }

        it { is_expected.to eq ['value has invalid child entry nyancat'] }
      end

      context 'when is array and one of the entries is invalid' do
        let(:value) { [entry] }
        let(:options) { { array: true } }

        it { is_expected.to eq ['value has invalid child entry nyancat'] }
      end
    end

    context 'child is invalid only for a different locale' do
      before do
        allow(entry).to receive(:valid?).and_return true
        allow(entry).to receive(:valid?).with(locale: :es).and_return false
      end
      let(:value) { entry }
      it { is_expected.to be_empty }

      context 'when calling validation and checking errors for that locale' do
        subject { fake_model.tap{ |_| fake_model.valid?(locale: :es) }.errors(locale: :es)[:fake_field] }
        it { is_expected.to eq ['value has invalid child entry nyancat'] }
      end
    end

    context 'child is invalid only for the current locale' do
      before do
        allow(entry).to receive(:valid?).and_return true
        allow(entry).to receive(:valid?).with(locale: :en).and_return false
      end
      let(:value) { entry }
      it { is_expected.to eq ['value has invalid child entry nyancat'] }
    end

    describe 'allowed_models' do
      let(:cat_entry) { cat_class.new(JSON.parse(File.read('fixtures/entries/nyancat.json'))) }
      let(:cat_class) { Class.new(ContentfulLite::Entry) }

      context 'when the entry is an allowed_model' do
        let(:value) { cat_entry }
        let(:options) { { allowed_models: [cat_class] } }

        it { is_expected.to be_empty }
      end

      context 'when the entry is not an allowed_model' do
        let(:value) { entry }
        let(:options) { { allowed_models: [cat_class] } }

        it { is_expected.to eq ["value has an invalid entry model. Expecting #{options[:allowed_models]}"] }
      end

      context 'when is array and all entries are allowed_models' do
        let(:value) { [cat_entry] }
        let(:options) { { allowed_models: [cat_class], array: true } }

        it { is_expected.to be_empty }
      end

      context 'when is array and one entry is not an allowed_model' do
        let(:value) { [cat_entry, entry] }
        let(:options) { { allowed_models: [cat_class], array: true } }

        it { is_expected.to eq ["value[1] has an invalid entry model. Expecting #{options[:allowed_models]}"] }
      end
    end
  end
end
