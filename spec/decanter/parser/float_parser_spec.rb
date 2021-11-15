require 'spec_helper'

describe 'FloatParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::FloatParser }

  describe '#parse' do
    context 'with a string' do
      context 'with a positive value' do
        it 'returns a positive float' do
          expect(parser.parse(name, '1.00')).to match({name => 1.00})
        end
      end

      context 'with a negative value' do
        it 'returns a negative float' do
          expect(parser.parse(name, '-1.00')).to match({name => -1.00})
        end
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
        expect { parser.parse(name, ['1.00']) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end
  end
end
