require 'spec_helper'

describe 'DateParser' do
  describe '#parse' do
    it 'returns a date' do
      expect(Decanter::ValueParser::DateParser.parse('2/21/1990')).to be_a Date
    end
  end
end
