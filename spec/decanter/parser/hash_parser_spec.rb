# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::HashParser do
  let(:hash_parser) { Class.new(described_class) }

  it 'calls the parser' do
    parser = ->(_a, _b, _c) { { a: 'b' } }
    allow(parser).to receive(:call).and_return({})
    hash_parser.parser(&parser)
    hash_parser._parse(:first_name, nil)
    expect(parser).to have_received(:call).with(:first_name, nil, {})
  end

  it 'raises an argument error if the parsing result is not a hash' do
    hash_parser.parser(&->(_a, _b, _c) { 5 })

    expect { hash_parser._parse(:first_name, nil) }
      .to raise_error(ArgumentError, 'Result of HashParser  was 5 when it must be a hash.')
  end
end
