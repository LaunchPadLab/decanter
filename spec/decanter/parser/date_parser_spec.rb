require 'spec_helper'

describe 'DateParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::DateParser }

  describe '#parse' do
    context 'with a valid date string of default form ' do
      it 'returns the date' do
        expect(parser.parse(name, '2/21/1990')).to match({name => Date.new(1990,2,21)})
      end
    end

    context 'with an invalid date string' do
      it 'raises an Argument Error' do
        expect { parser.parse(name, '2-21-1990') }
          .to raise_error(Decanter::ValueFormatError, 'invalid Date value for format')
      end
    end

    context 'with a date' do
      it 'returns the date' do
        expect(parser.parse(name, Date.new(1990,2,21))).to match({name => Date.new(1990,2,21)})
      end
    end

    context 'with a valid date string and custom format' do
      it 'returns the date' do
        expect(parser.parse(name, '2-21-1990', parse_format: '%m-%d-%Y')).to match({name => Date.new(1990,2,21)})
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
        expect { parser.parse(name, ['2-21-1990']) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end
  end
end
