require 'spec_helper'

describe 'JoinParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::JoinParser }

  describe '#parse' do
    context 'with an array of strings' do
      it 'returns a single joined string' do
        expect(parser.parse(name, ['a', 'b', 'c'])).to match({name => 'a,b,c'})
      end
    end

    context 'with an array of integers' do
      it 'returns a single joined string' do
        expect(parser.parse(name, [1, 2, 3])).to match({name => '1,2,3'})
      end
    end

    context 'with a custom delimiter' do
      it 'joins items using the delimiter' do
        expect(parser.parse(name, ['a', 'b', 'c'], delimiter: ':')).to match({name => 'a:b:c'})
      end
    end

    context 'with an empty array' do
      it 'returns nil' do
        expect(parser.parse(name, [])).to match({name => nil})
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
