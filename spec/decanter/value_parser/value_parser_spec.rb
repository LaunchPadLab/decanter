require 'spec_helper'

describe Decanter::ValueParser do

  before(:all) do
    Object.const_set('FooParser',
      Class.new(Decanter::ValueParser::Base) do
        def self.name
          'FooParser'
        end
      end
    )
  end

  describe '#parser_for' do

    context 'for a string' do

      let(:foo) { 'Foo' }

      it 'raises an argument error' do
        expect { Decanter::ValueParser::parser_for(foo) }
          .to raise_error(ArgumentError, "cannot lookup parser for #{foo} with class #{foo.class}")
      end
    end

    context 'for a class' do

      context 'when a corresponding parser does not exist' do

        let(:foo) do
          Class.new do
            def self.name
              'Foobar'
            end
          end
        end

        it 'raises a name error' do
          expect { Decanter::ValueParser::parser_for(foo) }
            .to raise_error(NameError, "uninitialized constant #{foo.name.concat('Parser')}")
        end
      end

      context 'when a corresponding parser exists' do

        let(:foo) do
          Class.new do
            def self.name
              'Foo'
            end
          end
        end

        it 'returns the parser' do
          expect(Decanter::ValueParser::parser_for(foo)).to eq FooParser
        end
      end
    end

    context 'for a symbol' do

      let(:foo) { :foobar }

      context 'when a corresponding parser does not exist' do
        it 'raises a name error' do
          expect { Decanter::ValueParser::parser_for(foo) }
            .to raise_error(NameError, "uninitialized constant #{foo.to_s.capitalize.concat('Parser')}")
        end
      end

      context 'when a corresponding parser exists' do

        let(:foo) { :foo }

        it 'returns the parser' do
          expect(Decanter::ValueParser::parser_for(foo)).to eq FooParser
        end
      end
    end
  end
end
