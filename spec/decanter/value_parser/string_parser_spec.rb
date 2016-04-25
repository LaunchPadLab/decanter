require 'spec_helper'

describe 'StringParser' do
  describe '#parse' do
    it 'returns a string' do
      expect(Decanter::Parser::StringParser.parse(:foo, 8)).to match({:foo => '8'})
    end
  end
end
