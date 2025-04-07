# frozen_string_literal: true

require 'spec_helper'

describe 'BooleanParser' do
  let(:parser) { Decanter::Parser::BooleanParser }

  describe '#parse' do
    trues = [
      ['number', 1],
      ['string', 1],
      ['boolean', true],
      %w[string true],
      %w[string True],
      %w[string truE]
    ]

    falses = [
      ['number', 0],
      ['number', 2],
      ['string', '2'],
      ['boolean', false],
      ['string', 'tru'],
      ['string', 'not true']
    ]

    let(:name) { :foo }

    context 'returns true for' do
      trues.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match({ name => true })
        end
      end
    end

    context 'returns false for' do
      falses.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match({ name => false })
        end
      end
    end

    context 'with empty string' do
      it 'returns nil' do
        expect(parser.parse(name, '')).to match({ name => nil })
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to match({ name => nil })
      end
    end

    context 'with array value' do
      it 'raises an exception' do
        expect { parser.parse(name, ['true']) }
          .to raise_error(Decanter::ParseError)
        expect { parser.parse(name, []) }
          .to raise_error(Decanter::ParseError)
      end
    end
  end
end
