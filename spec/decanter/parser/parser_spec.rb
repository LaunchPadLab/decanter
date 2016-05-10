require 'spec_helper'

describe Decanter::Parser do

  before(:all) do

    Object.const_set('FooParser',
      Class.new(Decanter::Parser::Base) do
        def self.name
          'FooParser'
        end
      end
    )

    Object.const_set('BarParser',
      Class.new(Decanter::Parser::Base) do
        def self.name
          'BarParser'
        end
      end.tap do |parser|
        parser.pre :date, :float
      end
    )
  end

  describe '#klass_or_sym_to_str' do

    subject { Decanter::Parser.klass_or_sym_to_str(klass_or_sym) }

    context 'for a string' do

      let(:klass_or_sym) { 'Foo' }

      it 'raises an argument error' do
        expect { subject }
          .to raise_error(ArgumentError, "cannot lookup parser for #{klass_or_sym} with class #{klass_or_sym.class}")
      end
    end

    context 'for a class' do

      let(:klass_or_sym) do
        Class.new do
          def self.name
            'Foobar'
          end
        end
      end

      it 'returns the name of the class + Parser' do
        expect(subject).to eq 'FoobarParser'
      end
    end

    context 'for a symbol' do

      let(:klass_or_sym) { :hot_dogs }

      it 'returns the singularized, camelized string + Parser' do
        expect(subject).to eq 'HotDogParser'
      end
    end
  end

  describe '#parser_constantize' do

    subject { Decanter::Parser.parser_constantize(parser_str) }

    context 'when a corresponding parser does not exist' do

      let(:parser_str) { 'FoobarParser' }

      it 'raises a name error' do
        expect { subject }
          .to raise_error(NameError, "cannot find parser #{parser_str.concat('Parser')}")
      end
    end

    context 'when a corresponding parser exists' do

      let(:parser_str) { 'FooParser' }

      it 'returns the parser' do
        expect(subject).to eq FooParser
      end
    end
  end

  describe '#expand' do

    subject { Decanter::Parser.expand(parser) }

    context 'when there are no preparsers' do

      let(:parser) { Class.new(Decanter::Parser::Base) }

      it 'returns an array only containing the original parser' do
        expect(subject).to eq [parser]
      end
    end

    context 'when there are preparsers' do

      let(:parser) {
        Class.new(Decanter::Parser::Base).tap do |parser|
          parser.pre :date
        end
      }

      it 'returns an array with the preparsers prepended to the original parser' do
        expect(subject).to eq [Decanter::Parser::DateParser, parser]
      end
    end
  end


  describe '#parsers_for' do

    subject { Decanter::Parser.parsers_for(:bar) }

    it 'returns a flattened array of parsers' do
      expect(subject).to eq [
        Decanter::Parser::DateParser,
        Decanter::Parser::FloatParser,
        BarParser
      ]
    end
  end
end
