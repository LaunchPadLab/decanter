require 'spec_helper'

describe 'RequiredParser' do

  let(:parser) { Decanter::Parser::RequiredParser }

  let(:name) { 'name' }

  describe '#parse' do

    context 'when required is false' do

      let(:options) { {} }

      context 'when the value is nil' do

        let(:value) { nil }

        it 'returns the value' do
          expect(parser.parse(name, value, options)).to match({name => value})
        end
      end

      context 'when the value is not nil' do

        let(:value) { 'value' }

        it 'returns the value' do
          expect(parser.parse(name, value, options)).to match({name => value})
        end
      end
    end

    context 'when required is true' do

      let(:options) { { required: true } }

      context 'when the value is nil' do

        let(:value) { nil }

        it 'raises an argument error' do
          expect { parser.parse(name, value, options) }
            .to raise_error(ArgumentError, "No value for required argument: #{name}")
        end
      end

      context 'when the value is not nil' do

        let(:value) { 'value' }

        it 'returns the value' do
          expect(parser.parse(name, value, options)).to match({name => value})
        end
      end
    end
  end
end
