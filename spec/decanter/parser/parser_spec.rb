# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser do
  before(:all) do
    Object.const_set('FooParser',
                     Class.new(Decanter::Parser::ValueParser) do
                       def self.name
                         'FooParser'
                       end
                     end)

    Object.const_set('BarParser',
                     Class.new(Decanter::Parser::ValueParser) do
                       def self.name
                         'BarParser'
                       end
                     end)
    BarParser.pre :date, :float

    Object.const_set('CheckInFieldDataParser',
                     Class.new(Decanter::Parser::ValueParser) do
                       def self.name
                         'BarParser'
                       end
                     end)
    CheckInFieldDataParser.pre :date, :float
  end

  describe '#parsers_for' do
    subject { Decanter::Parser.parsers_for(:bar) }

    let(:_data) { Decanter::Parser.parsers_for(:check_in_field_data) }

    it 'returns a flattened array of parsers' do
      expect(subject).to eq [
        Decanter::Parser::DateParser,
        Decanter::Parser::FloatParser,
        BarParser
      ]
    end

    it 'returns Data instead of Datum' do
      expect(_data).to eq [
        Decanter::Parser::DateParser,
        Decanter::Parser::FloatParser,
        CheckInFieldDataParser
      ]
    end
  end
end
