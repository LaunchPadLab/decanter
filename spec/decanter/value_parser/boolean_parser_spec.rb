require 'spec_helper'

describe Decanter::ValueParser::BooleanParser do
  describe '#parse' do
    context '1' do
      it 'returns true' do
        expect(Decanter::ValueParser::BooleanParser.parse(1)).to be true
      end
    end

    context 'foo' do
      it 'returns false' do
        expect(Decanter::ValueParser::BooleanParser.parse('foo')).to be false
      end
    end
  end
end
