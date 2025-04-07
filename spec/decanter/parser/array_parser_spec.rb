# frozen_string_literal: true

require 'spec_helper'

describe 'ArrayParser' do
  let(:name) { :foo }

  let(:parser) { Decanter::Parser::ArrayParser }

  describe '#parse' do
    context 'with an empty array' do
      it 'returns an empty array' do
        expect(parser.parse(name, [])).to match({ name => [] })
      end
    end

    context 'with an array of "empty" values' do
      it 'returns an empty array' do
        expect(parser.parse(name, [''])).to match({ name => [] })
      end
    end

    context 'with no parse_each option' do
      it 'defaults to PassParser' do
        expect(parser.parse(name, [1, '2'])).to match({ name => [1, '2'] })
      end
    end

    context 'with parse_each option' do
      context 'with single parser' do
        it 'applies the parser' do
          expect(parser.parse(name, [1, 2, 3],
                              parse_each: :string)).to match({ name => %w[1 2 3] })
        end
      end

      context 'with multiple parsers' do
        it 'applies all parsers' do
          expect(parser.parse(name, [0, 1],
                              parse_each: %i[boolean string])).to eq({ name => %w[false true] })
        end
      end

      context 'with non-value parser' do
        let(:foo_parser) { Class.new(Decanter::Parser::HashParser) }
        it 'raises an exception' do
          # Mock parser lookup
          allow(Decanter::Parser)
            .to receive(:parsers_for)
            .and_return(Array.wrap(foo_parser))
          expect { parser.parse(name, [1, 2, 3], parse_each: :foo) }
            .to raise_error(Decanter::ParseError)
        end
      end
    end

    context 'with a non-array argument' do
      it 'raises an exception' do
        expect { parser.parse(name, 123) }
          .to raise_error(Decanter::ParseError)
      end
    end

    # NOTE: this follows example above,
    # but it's still worth testing since it departs from the behavior of other parsers.
    context 'with empty string' do
      it 'raises an exception' do
        expect { parser.parse(name, '') }
          .to raise_error(Decanter::ParseError)
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to match({ name => nil })
      end
    end
  end
end
