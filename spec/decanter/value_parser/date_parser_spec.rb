require 'spec_helper'

describe 'DateParser' do
  describe '#parse' do
    context 'with a valid date string of default form ' do
      it 'returns a date' do
        expect(Decanter::ValueParser::DateParser.parse('2/21/1990')).to eq Date.new(2,21,1990)
      end
    end
  end
end
