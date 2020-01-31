require 'spec_helper'

describe 'FloatParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::FloatParser }

  describe '#parse' do
    context 'with a string' do
      it 'returns a float' do
        expect(parser.parse(name, '1.00')).to match({name => 1.00})
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
  end
end
