require 'spec_helper'

describe 'StringParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::StringParser }

  describe '#parse' do
    context 'with integer' do
      it 'returns string' do
        expect(parser.parse(name, 8)).to match({name => '8'})
      end
    end

    context 'with string' do
      it 'returns a string' do
        expect(parser.parse(name, 'bar')).to match({name => 'bar'})
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
        expect { parser.parse(name, [8]) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end
  end
end
