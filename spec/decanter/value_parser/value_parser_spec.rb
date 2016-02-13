require 'spec_helper'

describe Decanter::ValueParser do

  describe '#register' do
    before(:each) { Decanter::ValueParser.class_variable_set(:@@value_parsers, {}) }
    after(:each) { Decanter::ValueParser.class_variable_set(:@@value_parsers, {}) }

    it 'adds the class to the array of value_parsers' do
      foo = Class.new do
        def self.name
          'Foo'
        end
      end
      Decanter::ValueParser.register(foo)
      expect(Decanter::ValueParser.class_variable_get(:@@value_parsers)).to match({'Foo' => foo})
    end
  end

  describe '#value_parser_for' do

    context 'when a corresponding value_parser does not exist' do
      it 'raises a name error' do
        expect { Decanter::ValueParser::value_parser_for(:foo) }
          .to raise_error(NameError, "unknown value parser FooParser")
      end
    end

    context 'when a corresponding value_parser exists' do

      let(:foo_parser) do
        Class.new do
          def self.name
            'FooParser'
          end
        end
      end

      before(:each) do
        Decanter::ValueParser.register(foo_parser)
      end

      it 'returns the value_parser' do
        expect(Decanter::ValueParser.value_parser_for(:foo)).to eq foo_parser
      end
    end
  end
end
