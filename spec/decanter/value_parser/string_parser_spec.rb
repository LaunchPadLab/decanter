require 'spec_helper'

describe 'StringParser' do
  describe '#parse' do
    it 'returns a string' do
      expect(Decanter::ValueParser::StringParser.parse('foo', 8)).to be_a String
    end
  end
end
