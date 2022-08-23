require 'spec_helper'

describe 'BooleanParser' do

  let(:parser) { Decanter::Parser::BooleanParser }

  describe '#parse' do

    trues = [
      ['number', 1],
      ['string', 1],
      ['boolean', true],
      ['string', 'true'],
      ['string', 'True'],
    ]

    falses = [
      ['number', 0],
      ['number', 2],
      ['string', '2'],
      ['boolean', false],
    ]

    trues_with_options = [
      ['string', 'yes', 'string', 'yes'],
      ['string', 'Yes', 'string', 'yes'],
      ['string', 'is true', 'string', 'is true'],
      ['string', 'is truE', 'string', 'is True'],
      ['number', 3, 'number', 3],
      ['number', 3, 'string', '3'],
      ['string', '3', 'number', 3],
    ]

    falses_with_options = [
      ['string', 'false', 'string', 'false'],
      ['string', 'false', 'string', 'False'],
      ['string', 'yes', 'string', ''],
    ]

    let(:name) { :foo }

    context 'returns true for' do
      trues.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match({name => true})
        end
      end
    end

    context 'returns false for' do
      falses.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match({name => false})
        end
      end
    end

    context 'with empty string' do
      it 'returns nil' do
        expect(parser.parse(name, '')).to match({name => nil})
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to match({name => nil})
      end
    end

    context 'with array value' do
      it 'raises an exception' do
        expect { parser.parse(name, ['true']) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end

    context 'returns true with options for' do
      trues_with_options.each do |cond|
        it "#{cond[0]}: #{cond[1]}, option: {#{cond[2]}: #{cond[3]}}" do
          expect(parser.parse(name, cond[1], true_value: cond[3])).to match({name => true})
        end
      end
    end

    context 'returns false with options for' do
      falses_with_options.each do |cond|
        it "#{cond[0]}: #{cond[1]}, option: {#{cond[2]}: #{cond[3]}}" do
          expect(parser.parse(name, cond[1], true_value: cond[3])).to match({name => false})
        end
      end
    end

    context 'with empty string and empty options' do
      it 'returns nil' do
        expect(parser.parse(name, '', true_value: '')).to match({name => nil})
      end
    end

    context 'with nil and nil options' do
      it 'returns nil' do
        expect(parser.parse(name, nil, true_value: nil)).to match({name => nil})
      end
    end
  end
end
