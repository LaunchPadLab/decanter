require 'spec_helper'

# rubocop:disable Style/DateTime
describe 'DateTimeParser' do
  let(:name) { :foo }

  let(:parser) { Decanter::Parser::DateTimeParser }

  describe '#parse' do
    context 'with a valid datetime string of default form ' do
      it 'returns the datetime' do
        expect(parser.parse(name, '21/2/1990 04:15:16 PM')).to match(name => DateTime.new(1990, 2, 21, 16, 15, 16))
      end
    end

    context 'with an invalid date string' do
      it 'raises an Argument Error' do
        expect { parser.parse(name, '2-21-1990') }
          .to raise_error(ArgumentError)
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to match(name => nil)
      end
    end

    context 'with a datetime' do
      it 'returns the datetime' do
        expect(parser.parse(name, DateTime.new(1990, 2, 21))).to match(name => DateTime.new(1990, 2, 21))
      end
    end

    context 'with a valid date string and custom format' do
      it 'returns the date' do
        expect(parser.parse(name, '2-21-1990', parse_format: '%m-%d-%Y')).to match(name => DateTime.new(1990, 2, 21))
      end
    end
  end
end
# rubocop:enable Style/DateTime
