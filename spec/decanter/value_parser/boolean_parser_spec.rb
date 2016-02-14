require 'spec_helper'

describe 'BooleanParser' do

  let(:parser) { Decanter::ValueParser::BooleanParser }

  describe '#parse' do

    trues = [
      ['number', 1],
      ['string', 1],
      ['boolean', true],
      ['string', 'true'],
      ['string', 'True'],
      ['string', 'truE']
    ]

    falses = [
      ['number', 0],
      ['number', 2],
      ['string', 2],
      ['boolean', false],
      ['string', 'tru']
    ]

    context 'is true when' do
      trues.each do |cond|
        it "is #{cond[0]}: #{cond[1]}" do
          expect(parser.parse(cond[1])).to be true
        end
      end
    end

    context 'is false when' do
      falses.each do |cond|
        it "is #{cond[0]}: #{cond[1]}" do
          expect(parser.parse(cond[1])).to be false
        end
      end
    end
  end
end
