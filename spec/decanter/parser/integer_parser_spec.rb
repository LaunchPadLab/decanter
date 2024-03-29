require 'spec_helper'

describe 'IntegerParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::IntegerParser }

  describe '#parse' do
    context 'with a string' do
      context 'with a positive value' do
        it 'returns a positive integer' do
          expect(parser.parse(name, '1')).to eq({ foo: 1 })
        end
      end

      context 'with a negative value' do
        it 'returns a negative integer' do
          expect(parser.parse(name, '-1')).to eq({ foo: -1 })
        end
      end
    end

    context 'with empty string' do
      it 'returns nil' do
        expect(parser.parse(name, '')).to eq({ foo: nil })
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to eq({ foo: nil })
      end
    end

    context 'with array value' do
      it 'raises an exception' do
        expect { parser.parse(name, ['1']) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end
  end
end
