# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::HashParser do
  let(:hash_parser) { Class.new(described_class) }

  it 'calls the parser' do
    parser = ->(_a, _b) { { a: 'b' } }
    allow(parser).to receive(:call).and_return({})
    hash_parser.parser(&parser)
    hash_parser._parse(nil)
    expect(parser).to have_received(:call).with(nil, {})
  end

  it 'raises an argument error if the parsing result is not a hash' do
    hash_parser.parser(&->(_a, _b) { 5 })

    expect { hash_parser._parse(nil) }
      .to raise_error(ArgumentError, 'Result of HashParser was 5 when it must be a hash.')
  end
end
