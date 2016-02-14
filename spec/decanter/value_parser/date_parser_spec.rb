require 'spec_helper'

describe 'DateParser' do

  let(:parser) { Decanter::ValueParser::DateParser }

  describe '#parse' do
    context 'with a valid date string of default form ' do
      it 'returns the date' do
        expect(parser.parse('2/21/1990')).to eq Date.new(1990,2,21)
      end
    end

    context 'with an invalid date string' do
      it 'raises an Argument Error' do
        expect { parser.parse('2-21-1990') }
          .to raise_error(ArgumentError, 'invalid date')
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(nil)).to eq nil
      end
    end

    context 'with a date' do
      it 'returns the date' do
        expect(parser.parse(Date.new(1990,2,21))).to eq Date.new(1990,2,21)
      end
    end

    context 'with a valid date string and custom format' do
      it 'returns the date' do
        expect(parser.parse('2-21-1990', parse_format: '%m-%d-%Y')).to eq Date.new(1990,2,21)
      end
    end
  end
end
