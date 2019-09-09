# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe Decanter::Core do
  let(:dummy) { Class.new(Decanter::Base) }

  before(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
  end

  after(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
  end

  describe '#input' do
    let(:name) { :profile }
    let(:parser) { :string }
    let(:options) { {} }

    before(:each) { dummy.input name, parser, options }

    it 'adds a handler for the provided name' do
      expect(dummy.handlers.key?(name)).to be true
    end

    context 'for multiple name values' do
      let(:name) { %i(first_name last_name) }

      it 'adds a handler for the provided name' do
        expect(dummy.handlers.key?(name)).to be true
      end

      it 'raises an error if multiple values are passed without a parser' do
        expect { dummy.input name }.to raise_error(ArgumentError)
      end
    end

    it 'the handler has type :input' do
      expect(dummy.handlers[name][:type]).to eq :input
    end

    it 'the handler has default key equal to the name' do
      expect(dummy.handlers[name][:key]).to eq name
    end

    it 'the handler passes through the options' do
      expect(dummy.handlers[name][:options]).to eq options
    end

    it 'the handler has parser of provided parser' do
      expect(dummy.handlers[name][:parsers]).to eq [parser]
    end

    context 'with key specified in options' do
      let(:options) { { key: :foo } }

      it 'the handler has key from options' do
        expect(dummy.handlers[name][:key]).to eq options[:key]
      end
    end
  end

  describe '#has_one' do
    let(:assoc) { :profile }
    let(:name) { ["#{assoc}_attributes".to_sym] }
    let(:options) { {} }

    before(:each) { dummy.has_one assoc, options }

    it 'adds a handler for the association' do
      expect(dummy.handlers.key?(assoc)).to be true
    end

    it 'the handler has type :has_one' do
      expect(dummy.handlers[assoc][:type]).to eq :has_one
    end

    it 'the handler has default key :profile' do
      expect(dummy.handlers[assoc][:key]).to eq assoc
    end

    it 'the handler passes through the options' do
      expect(dummy.handlers[assoc][:options]).to eq options
    end

    it 'the handler has assoc = provided assoc' do
      expect(dummy.handlers[assoc][:assoc]).to eq assoc
    end

    context 'with key specified in options' do
      let(:options) { { key: :foo } }

      it 'the handler has key from options' do
        expect(dummy.handlers[assoc][:key]).to eq options[:key]
      end
    end
  end

  describe '#has_many' do
    let(:assoc) { :profile }
    let(:name) { ["#{assoc}_attributes".to_sym] }
    let(:options) { {} }

    before(:each) { dummy.has_many assoc, options }

    it 'adds a handler for the assoc' do
      expect(dummy.handlers.key?(assoc)).to be true
    end

    it 'the handler has type :has_many' do
      expect(dummy.handlers[assoc][:type]).to eq :has_many
    end

    it 'the handler has default key :profile' do
      expect(dummy.handlers[assoc][:key]).to eq assoc
    end

    it 'the handler has assoc = provided assoc' do
      expect(dummy.handlers[assoc][:assoc]).to eq assoc
    end

    it 'the handler passes through the options' do
      expect(dummy.handlers[assoc][:options]).to eq options
    end

    context 'with key specified in options' do
      let(:options) { { key: :foo } }

      it 'the handler has key from options' do
        expect(dummy.handlers[assoc][:key]).to eq options[:key]
      end
    end
  end

  describe '#strict' do
    let(:mode) { true }

    it 'sets the strict mode' do
      dummy.strict mode
      expect(dummy.strict_mode).to eq mode
    end

    context 'for an unknown mode' do
      let(:mode) { :foo }

      it 'raises an error' do
        expect { dummy.strict mode }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#parse' do
    context 'when a parser is not specified' do
      let(:parser) { double('parser', parse: nil) }

      before(:each) do
        allow(Decanter::Parser)
          .to receive(:parsers_for)
          .and_return(Array.wrap(parser))
      end

      it 'returns the provided value' do
        expect(dummy.parse(nil, 'bar', {})).to eq('bar')
      end

      it 'does not call Parser.parsers_for' do
        dummy.parse(nil, 'bar', {})
        expect(Decanter::Parser).to_not have_received(:parsers_for)
      end
    end

    context 'when one parser is specified' do
      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(:float, val.to_s, {})).to eq(val)
      end
    end

    context 'when one parser is specified' do
      let(:val) { 'a:b,c:d' }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(:key_value_splitter, val, {})).to eq('a' => 'b', 'c' => 'd')
      end
    end

    context 'when several parsers are specified' do
      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(%i(string float), val, {})).to eq(val)
      end
    end

    context 'when a parser with a preparser is specified' do
      PctParser = Class.new(Decanter::Parser::ValueParser) do
        pre :float

        parser do |val, _options|
          val / 100
        end
      end

      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(%i(string pct), val, {})).to eq(val / 100)
      end
    end

    context 'when a hash parser and other parsers are specified' do
      let(:val) { 'foo:3.45,baz:91' }

      it 'returns the a key-value pairs with the parsed values' do
        expect(dummy.parse(%i(key_value_splitter pct), val, {}))
          .to eq('foo' => 0.0345, 'baz' => 0.91)
      end
    end
  end

  describe '#decanter_for_handler' do
    context 'when decanter option is specified' do
      let(:handler) { { options: { decanter: 'FooDecanter' } } }

      before(:each) { allow(Decanter).to receive(:decanter_from) }

      it 'calls Decanter::decanter_from with the specified decanter' do
        dummy.decanter_for_handler(handler)
        expect(Decanter).to have_received(:decanter_from).with(handler[:options][:decanter])
      end
    end

    context 'when decanter option is not specified' do
      let(:handler) { { assoc: :foo, options: {} } }

      before(:each) { allow(Decanter).to receive(:decanter_for) }

      it 'calls Decanter::decanter_for with the assoc' do
        dummy.decanter_for_handler(handler)
        expect(Decanter).to have_received(:decanter_for).with(handler[:assoc])
      end
    end
  end

  describe '#unhandled_keys' do
    let(:args) { { foo: :bar } }

    context 'when there are no unhandled keys' do
      before(:each) { allow(dummy).to receive(:handlers).and_return(foo: { type: :input }) }

      it 'returns an empty hash' do
        expect(dummy.unhandled_keys(args)).to match({})
      end
    end

    context 'when there are unhandled keys' do
      before(:each) { allow(dummy).to receive(:handlers).and_return({}) }

      context 'and strict mode is true' do
        it 'spits out a warning' do
          dummy.strict true
          # Not sure how to test this
          true
        end
      end

      context 'and strict mode is :with_exception' do
        before(:each) { dummy.strict :with_exception }

        context 'when there are no ignored keys' do
          it 'raises an error' do
            expect { dummy.unhandled_keys(args) }.to raise_error(Decanter::Core::UnhandledKeysError)
          end
        end

        context 'when the unhandled keys are ignored' do
          it 'does not raise an error' do
            dummy.ignore :foo
            expect { dummy.unhandled_keys(args) }.not_to raise_error
          end
        end
      end

      context 'and strict mode is false' do
        it 'returns a hash with the unhandled keys and values' do
          dummy.strict false
          expect(dummy.unhandled_keys(args)).to match(args)
        end
      end
    end
  end

  describe '#handle' do
    let(:name)    { :name }
    let(:parser)  { double('parser') }
    let(:options) { double('options') }
    let(:values)  { 'Hi' }
    let(:handler) { { key: name, name: name, parsers: parser, options: options, type: :input } }

    before(:each) do
      allow(dummy).to receive(:parse)
    end

    it 'calls parse with the handler key, handler parser, values and options' do
      dummy.handle(handler, values)
      expect(dummy)
        .to have_received(:parse)
        .with(parser, values, options)
    end
  end

  describe '#decant' do
    subject { dummy.decant(args) }

    let(:args) { { foo: 'bar', baz: 'foo' } }
    let(:is_required) { true }

    let(:input_hash) do
      {
        key: 'sky',
        options: {
          required: is_required
        }
      }
    end
    let(:handler) { [:title, input_hash] }
    let(:handlers) { [handler] }

    before(:each) do
      allow(dummy).to receive(:unhandled_keys).and_return(args)
      allow(dummy).to receive(:handled_keys).and_return(args)
    end

    context 'with args' do
      context 'when inputs are required' do
        it 'should raise an exception if no required values' do
          allow(dummy).to receive(:handlers).and_return(handlers)

          expect { subject }.to raise_error(
            Decanter::Core::MissingRequiredInputValue
          )
        end
      end

      it 'passes the args to unhandled keys' do
        subject
        expect(dummy).to have_received(:unhandled_keys).with(args)
      end

      it 'passes the args to handled keys' do
        subject
        expect(dummy).to have_received(:handled_keys).with(args)
      end

      it 'returns the merged result' do
        expect(subject).to eq args.merge(args)
      end

      context 'with ActionController::Parameters' do
        let(:params) { ActionController::Parameters.new(args) }
        subject { dummy.decant(params) }

        it 'passes the args to unhandled keys' do
          subject
          expect(dummy).to have_received(:unhandled_keys).with(args)
        end

        it 'passes the args to handled keys' do
          subject
          expect(dummy).to have_received(:handled_keys).with(args)
        end

        it 'returns the merged result' do
          expect(subject).to eq args.merge(args)
        end
      end
    end

    context 'with missing non-required args' do
      let(:decanter) {
        Class.new(Decanter::Base) do
          input :name, :string
          input :description, :string
        end
      }
      let(:params) { { description: 'My Trip Description' } }
      it 'should omit missing values' do
        decanted_params = decanter.decant(params)
        # :description wasn't sent, so it shouldn't be in the result
        expect(decanted_params).to eq(params)
      end
    end

    context 'without args' do
      let(:args) { nil }
      let(:is_required) { true }

      context 'when at least one input is required' do
        it 'should raise an exception' do
          allow(dummy).to receive(:handlers).and_return(handlers)
          expect { subject }.to raise_error(Decanter::Core::MissingRequiredInputValue)
        end
      end

      context 'when no inputs are required' do
        let(:is_required) { false }

        it 'should return an empty hash' do
          expect(subject).to eq({})
        end
      end
    end
  end

  describe 'required_input_keys_present?' do
    let(:is_required) { true }
    let(:args) { { "title": 'RubyConf' } }
    let(:input_hash) do
      {
        key: 'foo',
        options: {
          required: is_required
        }
      }
    end
    let(:handler) { [:title, input_hash] }
    let(:handlers) { [handler] }
    before(:each) { allow(dummy).to receive(:handlers).and_return(handlers) }

    context 'when required args are present' do
      it 'should return true' do
        result = dummy.required_input_keys_present?(args)
        expect(result).to be true
      end
    end

    context 'when required args are not present' do
      let(:args) { { name: 'Bob' } }
      it 'should return false' do
        result = dummy.required_input_keys_present?(args)
        expect(result).to be false
      end
    end
  end
end
