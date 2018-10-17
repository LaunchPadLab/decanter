# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::ValueParser do
  let(:value_parser) { Class.new(described_class) }

  it 'calls the parser' do
    parser = ->(_a, _b, _c) { { a: 'b' } }
    allow(parser).to receive(:call).and_return({})
    value_parser.parser(&parser)
    value_parser._parse(nil)
    expect(parser).to have_received(:call).with(nil, {})
  end
end
