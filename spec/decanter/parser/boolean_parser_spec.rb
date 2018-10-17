# frozen_string_literal: true

require 'spec_helper'

describe 'BooleanParser' do
  let(:parser) { Decanter::Parser::BooleanParser }

  describe '#parse' do
    trues = [
      ['number', 1],
      ['string', 1],
      ['boolean', true],
      %w(string true),
      %w(string True),
      %w(string truE)
    ]

    falses = [
      ['number', 0],
      ['number', 2],
      ['string', 2],
      ['boolean', false],
      %w(string tru)
    ]

    let(:name) { :foo }

    context 'returns true for' do
      trues.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match(name => true)
        end
      end
    end

    context 'returns false for' do
      falses.each do |cond|
        it "#{cond[0]}: #{cond[1]}" do
          expect(parser.parse(name, cond[1])).to match(name => false)
        end
      end
    end
  end
end
