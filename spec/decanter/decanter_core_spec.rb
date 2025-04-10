require 'spec_helper'

describe Decanter::Core do
  let(:dummy) { Class.new { include Decanter::Core } }

  before(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
  end

  after(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
  end

  describe '#input' do
    let(:name) { [:profile] }
    let(:parser) { :string }
    let(:options) { {} }

    before(:each) { dummy.input(name, parser, **options) }

    it 'adds a handler for the provided name' do
      expect(dummy.handlers.key?(name)).to be true
    end

    context 'for multiple values' do
      let(:name) { %i[first_name last_name] }

      it 'adds a handler for the provided name' do
        expect(dummy.handlers.has_key?(name)).to be true
      end

      it 'raises an error if multiple values are passed without a parser' do
        expect { dummy.input name }.to raise_error(ArgumentError)
      end
    end

    it 'the handler has type :input' do
      expect(dummy.handlers[name][:type]).to eq :input
    end

    it 'the handler has default key equal to the name' do
      expect(dummy.handlers[name][:key]).to eq name.first
    end

    it 'the handler has name = provided name' do
      expect(dummy.handlers[name][:name]).to eq name
    end

    it 'the handler passes through the options' do
      expect(dummy.handlers[name][:options]).to eq options
    end

    it 'the handler has parser of provided parser' do
      expect(dummy.handlers[name][:parsers]).to eq parser
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

    before(:each) { dummy.has_one(assoc, **options) }

    it 'adds a handler for the association' do
      expect(dummy.handlers.has_key?(assoc)).to be true
    end

    it 'the handler has type :has_one' do
      expect(dummy.handlers[assoc][:type]).to eq :has_one
    end

    it 'the handler has default key :profile' do
      expect(dummy.handlers[assoc][:key]).to eq assoc
    end

    it 'the handler has name = assoc' do
      expect(dummy.handlers[assoc][:name]).to eq assoc
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

    before(:each) { dummy.has_many(assoc, **options) }

    it 'adds a handler for the assoc' do
      expect(dummy.handlers.has_key?(assoc)).to be true
    end

    it 'the handler has type :has_many' do
      expect(dummy.handlers[assoc][:type]).to eq :has_many
    end

    it 'the handler has default key :profile' do
      expect(dummy.handlers[assoc][:key]).to eq assoc
    end

    it 'the handler has name = assoc' do
      expect(dummy.handlers[assoc][:name]).to eq assoc
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

  describe '#log_unhandled_keys' do
    let(:mode) { false }

    it 'sets the @log_unhandled_keys_mode' do
      dummy.log_unhandled_keys(mode)
      expect(dummy.log_unhandled_keys_mode).to eq mode
    end

    context 'for an unknown mode' do
      let(:mode) { :foo }

      it 'raises an error' do
        expect { dummy.log_unhandled_keys(mode) }.to raise_error(ArgumentError)
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

      it 'returns the provided key and value' do
        expect(dummy.parse(:first_name, nil, 'bar', {})).to eq({ first_name: 'bar' })
      end

      it 'does not call Parser.parsers_for' do
        dummy.parse(:first_name, nil, 'bar', {})
        expect(Decanter::Parser).to_not have_received(:parsers_for)
      end
    end

    context 'when a parser is specified but a required value is not present' do
      it 'raises an argument error specifying the key' do
        expect { dummy.parse(:first_name, :foo, nil, { required: true }) }
          .to raise_error(ArgumentError, 'No value for required argument: first_name')
      end
    end

    context 'when one parser is specified' do
      let(:key) { :afloat }
      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(key, :float, val.to_s, {})).to eq({ key => val })
      end
    end

    context 'when several parsers are specified' do
      let(:key) { :afloat }
      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(key, %i[string float], val, {})).to eq({ key => val })
      end
    end

    context 'when a parser with a preparser is specified' do
      Object.const_set('PctParser',
                       Class.new(Decanter::Parser::ValueParser) do
                         def self.name
                           'PctParser'
                         end
                       end.tap do |parser|
                         parser.pre :float
                         parser.parser do |val, _options|
                           val / 100
                         end
                       end)

      Object.const_set('KeyValueSplitterParser',
                       Class.new(Decanter::Parser::HashParser) do
                         def self.name
                           'KeyValueSplitterParser'
                         end
                       end.tap do |parser|
                         parser.parser do |_name, val, _options|
                           item_delimiter = ','
                           pair_delimiter = ':'
                           val.split(item_delimiter).reduce({}) do |memo, pair|
                             memo.merge(Hash[*pair.split(pair_delimiter)])
                           end
                         end
                       end)

      let(:key) { :afloat }
      let(:val) { 8.0 }

      it 'returns the a key-value pair with the parsed value' do
        expect(dummy.parse(key, %i[string pct], val, {})).to eq({ key => val / 100 })
      end
    end

    context 'when a hash parser and other parsers are specified' do
      let(:key) { :split_it! }
      let(:val) { 'foo:3.45,baz:91' }

      it 'returns the a key-value pairs with the parsed values' do
        expect(dummy.parse(key, %i[key_value_splitter pct], val, {}))
          .to eq({ 'foo' => 0.0345, 'baz' => 0.91 })
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
    let(:args) { { foo: :bar, 'baz' => 'foo' } }

    context 'when there are no unhandled keys' do
      before(:each) { allow(dummy).to receive(:handlers).and_return({ foo: { type: :input }, baz: { type: :input } }) }

      it 'returns an empty hash' do
        expect(dummy.unhandled_keys(args)).to match({})
      end
    end

    context 'when there are unhandled keys' do
      context 'and strict mode is true' do
        before(:each) { allow(dummy).to receive(:handlers).and_return({}) }
        before(:each) { dummy.strict true }

        context 'when there are no ignored keys' do
          it 'raises an error' do
            expect { dummy.unhandled_keys(args) }.to raise_error(Decanter::UnhandledKeysError)
          end
        end

        context 'when the unhandled keys are ignored' do
          it 'does not raise an error' do
            dummy.ignore :foo, 'baz'
            expect { dummy.unhandled_keys(args) }.to_not raise_error(Decanter::UnhandledKeysError)
          end
        end
      end

      context 'and strict mode is :ignore' do
        it 'returns a hash without the unhandled keys and values' do
          dummy.strict :ignore
          expect(dummy.unhandled_keys(args)).to match({})
        end

        it 'logs the unhandled keys' do
          dummy.strict :ignore
          expect { dummy.unhandled_keys(args) }.to output(/ignoring unhandled keys: foo, baz/).to_stdout
        end

        context 'and log_unhandled_keys mode is false' do
          it 'does not log the unhandled keys' do
            dummy.strict :ignore
            dummy.log_unhandled_keys false
            expect { dummy.unhandled_keys(args) }.not_to output(/ignoring unhandled keys: foo, baz/).to_stdout
          end
        end
      end

      context 'and strict mode is false' do
        it 'returns a hash with the unhandled keys and values' do
          dummy.strict false
          allow(dummy).to receive(:handlers).and_return({})
          expect(dummy.unhandled_keys(args)).to match(args)
        end
      end
    end
  end

  describe '#handle' do
    let(:args)    { { foo: 'hi', bar: 'bye' } }
    let(:name)    { %i[foo bar] }
    let(:values)  { args.values_at(*name) }
    let(:handler) { { type: :input, name: } }

    before(:each) { allow(dummy).to receive(:handle_input).and_return(:foobar) }

    context 'for an input' do
      it 'calls the handle_input with the handler and extracted values' do
        dummy.handle(handler, args)
        expect(dummy)
          .to have_received(:handle_input)
          .with(handler, values)
      end

      it 'returns the results form handle_input' do
        expect(dummy.handle(handler, args)).to eq :foobar
      end
    end
  end

  describe '#handle_input' do
    let(:name)    { :name }
    let(:parser)  { double('parser') }
    let(:options) { double('options') }
    let(:args)    { { name => 'Hi', foo: 'bar' } }
    let(:values)  { args[name] }
    let(:handler) { { key: name, name:, parsers: parser, options: } }

    before(:each) do
      allow(dummy).to receive(:parse)
    end

    it 'calls parse with the handler key, handler parser, values and options' do
      dummy.handle_input(handler, args)
      expect(dummy)
        .to have_received(:parse)
        .with(name, parser, values, options)
    end
  end

  describe '#handle_has_one' do
    let(:output)   { { foo: 'bar' } }
    let(:handler)  { { key: 'key', options: {} } }
    let(:values)   { { baz: 'foo' } }
    let(:decanter) { double('decanter') }

    before(:each) do
      allow(decanter)
        .to receive(:decant)
        .and_return(output)

      allow(dummy)
        .to receive(:decanter_for_handler)
        .and_return(decanter)
    end

    it 'calls decanter_for_handler with the handler' do
      dummy.handle_has_one(handler, values)
      expect(dummy)
        .to have_received(:decanter_for_handler)
        .with(handler)
    end

    it 'calls decant with the values on the found decanter' do
      dummy.handle_has_one(handler, values)
      expect(decanter)
        .to have_received(:decant)
        .with(values)
    end

    it 'returns an array containing the key, and the decanted value' do
      expect(dummy.handle_has_one(handler, values))
        .to match({ handler[:key] => output })
    end
  end

  describe '#handle_has_many' do
    let(:output)   { [{ foo: 'bar' }, { bar: 'foo' }] }
    let(:handler)  { { key: 'key', options: {} } }
    let(:values)   { [{ baz: 'foo' }, { faz: 'boo' }] }
    let(:decanter) { double('decanter') }

    before(:each) do
      allow(decanter)
        .to receive(:decant)
        .and_return(*output)

      allow(dummy)
        .to receive(:decanter_for_handler)
        .and_return(decanter)
    end

    it 'calls decanter_for_handler with the handler' do
      dummy.handle_has_many(handler, values)
      expect(dummy)
        .to have_received(:decanter_for_handler)
        .with(handler)
    end

    it 'calls decant with the each of the values on the found decanter' do
      dummy.handle_has_many(handler, values)
      expect(decanter)
        .to have_received(:decant)
        .with(values[0])
      expect(decanter)
        .to have_received(:decant)
        .with(values[1])
    end

    it 'returns an array containing the key, and an array of decanted values' do
      expect(dummy.handle_has_many(handler, values))
        .to match({ handler[:key] => output })
    end
  end

  describe '#handle_association' do
    let(:assoc) { :profile }
    let(:handler) do
      {
        assoc:,
        key: assoc,
        name: assoc,
        type: :has_one,
        options: {}
      }
    end

    before(:each) do
      allow(dummy).to receive(:handle_has_one)
    end

    context 'when there is a verbatim matching key' do
      let(:args) { { assoc => 'bar', :baz => 'foo' } }

      it 'calls handler_has_one with the handler and args' do
        dummy.handle_association(handler, args)
        expect(dummy)
          .to have_received(:handle_has_one)
          .with(handler, args[assoc])
      end
    end

    context 'when there is a matching key for _attributes' do
      let(:args) { { "#{assoc}_attributes".to_sym => 'bar', :baz => 'foo' } }

      it 'calls handler_has_one with the _attributes handler and args' do
        dummy.handle_association(handler, args)
        expect(dummy)
          .to have_received(:handle_has_one)
          .with(hash_including(name: "#{assoc}_attributes".to_sym), args[:profile_attributes])
      end
    end

    context 'when there is no matching key' do
      let(:args) { { foo: 'bar', baz: 'foo' } }

      it 'does not call handler_has_one' do
        dummy.handle_association(handler, args)
        expect(dummy).to_not have_received(:handle_has_one)
      end

      it 'returns an empty hash' do
        expect(dummy.handle_association(handler, args)).to eq({})
      end
    end

    context 'when there are multiple matching keys' do
      let(:args) { { "#{assoc}_attributes".to_sym => 'bar', assoc => 'foo' } }

      it 'raises an argument error' do
        expect { dummy.handle_association(handler, args) }
          .to raise_error(ArgumentError,
                          "Handler #{handler[:name]} matches multiple keys: [:profile, :profile_attributes].")
      end
    end
  end

  describe '#decant' do
    let(:args) { { foo: 'bar', baz: 'foo' } }
    let(:subject) { dummy.decant(args) }
    let(:is_required) { true }

    let(:input_hash) do
      {
        key: 'sky',
        options: {
          required: is_required
        }
      }
    end
    let(:handler) { [[:title], input_hash] }
    let(:handlers) { [handler] }

    before(:each) do
      allow(dummy).to receive(:unhandled_keys).and_return(args)
      allow(dummy).to receive(:handled_keys).and_return(args)
    end

    context 'with args' do
      context 'when strict mode is set to :ignore' do
        context 'and params include unhandled keys' do
          let(:decanter) do
            Class.new(Decanter::Base) do
              input :name, :string
              input :description, :string
            end
          end

          let(:args) { { name: 'My Trip', description: 'My Trip Description', foo: 'bar' } }

          it 'returns a hash with the declared key-value pairs, ignores unhandled key-value pairs' do
            decanter.strict :ignore
            decanted_params = decanter.decant(args)

            expect(decanted_params).not_to match(args)
            expect(decanted_params.keys).not_to include([:foo])
          end
        end
      end

      context 'when inputs are required' do
        let(:decanter) do
          Class.new do
            include Decanter::Core
            input :name, :pass, required: true
          end
        end
        it 'should raise an exception if required values are missing' do
          expect { decanter.decant({ name: nil }) }
            .to raise_error(Decanter::MissingRequiredInputValue)
        end
        it 'should not raise an exception if required values are present' do
          expect { decanter.decant({ name: 'foo' }) }
            .not_to raise_error
        end
        it 'should treat empty arrays as present' do
          expect { decanter.decant({ name: [] }) }
            .not_to raise_error
        end
        it 'should treat empty strings as missing' do
          expect { decanter.decant({ name: '' }) }
            .to raise_error(ArgumentError)
        end
        it 'should treat blank strings as present' do
          expect { decanter.decant({ name: '   ' }) }
            .not_to raise_error
        end
      end

      context 'when params keys are strings' do
        let(:decanter) do
          Class.new do
            include Decanter::Core
            input :name, :string
            input :description, :string
          end
        end
        let(:args) { { 'name' => 'My Trip', 'description' => 'My Trip Description' } }
        it 'returns a hash with the declared key-value pairs' do
          decanted_params = decanter.decant(args)
          expect(decanted_params.with_indifferent_access).to match(args)
        end
        it 'converts all keys to symbols in the merged result' do
          decanted_params = decanter.decant(args)
          expect(decanted_params.keys).to all(be_a(Symbol))
        end

        context 'and when inputs are strings' do
          let(:decanter) do
            Class.new do
              include Decanter::Core
              input 'name', :string
              input 'description', :string
            end
          end
          it 'returns a hash with the declared key-value pairs' do
            decanted_params = decanter.decant(args)
            expect(decanted_params.with_indifferent_access).to match(args)
          end
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
    end

    context 'with missing non-required args' do
      let(:decanter) do
        Class.new do
          include Decanter::Core
          input :name, :string
          input :description, :string
        end
      end
      let(:params) { { description: 'My Trip Description' } }
      it 'should omit missing values' do
        decanted_params = decanter.decant(params)
        # :name wasn't sent, so it shouldn't be in the result
        expect(decanted_params).to eq(params)
      end
    end

    context 'with key having a :default_value in the decanter' do
      let(:decanter) do
        Class.new do
          include Decanter::Core
          input :name, :string, default_value: 'foo'
          input :cost, :float, default_value: '99.99'
          input :description, :string
        end
      end

      it 'should include missing keys and their parsed default values' do
        params = { description: 'My Trip Description' }
        decanted_params = decanter.decant(params)
        desired_result = params.merge(name: 'foo', cost: 99.99)
        # :name wasn't sent, but it should have a default value of 'foo'
        # :cost wasn't sent, but it should have a parsed float default value of 99.99
        expect(decanted_params).to eq(desired_result)
        expect(decanted_params[:cost]).to be_kind_of(Float)
      end

      it 'should not override a (parsed) existing value' do
        params = { description: 'My Trip Description', name: 'bar', cost: '25.99' }
        decanted_params = decanter.decant(params)
        desired_result = params.merge(cost: 25.99)
        # :name has a default value of 'foo', but it was sent as and should remain 'bar'
        # :cost has default value of '99.99', but it was sent as '25.99'
        # and should have a parsed float value of 25.99
        expect(decanted_params).to eq(desired_result)
      end

      it 'should not override an existing nil value' do
        params = { description: 'My Trip Description', name: nil }
        decanted_params = decanter.decant(params)
        desired_result = params.merge(cost: 99.99)
        # :name has a default value of 'foo', but it was sent as and should remain nil
        expect(decanted_params).to eq(desired_result)
      end

      it 'should not override an existing blank value' do
        params = { description: 'My Trip Description', name: '', cost: '99.99' }
        decanted_params = decanter.decant(params)
        desired_result = params.merge(name: nil, cost: 99.99)
        # :name has a default value of 'foo', but it was sent as empty and should remain empty/nil
        expect(decanted_params).to eq(desired_result)
      end
    end

    context 'with present non-required args containing an empty value' do
      let(:decanter) do
        Class.new(Decanter::Base) do
          input :name, :string
          input :description, :string
        end
      end
      let(:params) { { name: '', description: 'My Trip Description' } }
      let(:desired_result) { { name: nil, description: 'My Trip Description' } }
      it 'should pass through the values' do
        decanted_params = decanter.decant(params)
        # :name should be in the result even though it was nil
        expect(decanted_params).to eq(desired_result)
      end
    end

    context 'without args' do
      let(:args) { nil }
      let(:inputs_required) { true }
      before(:each) do
        allow(dummy).to receive(:any_inputs_required?).and_return(inputs_required)
      end

      context 'when at least one input is required' do
        it 'should raise an exception' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when no inputs are required' do
        let(:inputs_required) { false }

        it 'should return an empty hash' do
          expect(subject).to eq({})
        end
      end
    end
  end

  describe 'any_inputs_required?' do
    let(:is_required) { true }
    let(:input_hash) do
      {
        key: 'foo',
        options: {
          required: is_required
        }
      }
    end
    let(:handler) { [[:title], input_hash] }
    let(:handlers) { [handler] }
    before(:each) do
      allow(dummy).to receive(:handlers).and_return(handlers)
    end

    context 'when required' do
      it 'should return true' do
        expect(dummy.any_inputs_required?).to be true
      end
    end

    context 'when not required' do
      let(:is_required) { false }
      it 'should return false' do
        expect(dummy.any_inputs_required?).to be false
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
    let(:handler) { [[:title], input_hash] }
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
