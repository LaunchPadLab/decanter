require 'spec_helper'

describe 'HashParser' do

  let(:hash_parser) { Class.new(Decanter::Parser::HashParser) }

  it 'calls the parser' do
    parser = lambda { |a,b,c| {a: 'b'} }
    allow(parser).to receive(:call).and_return({})
    hash_parser.parser &parser
    hash_parser._parse(:first_name, nil)
    expect(parser).to have_received(:call).with(:first_name, nil, {})
  end

  it 'raises an argument error if the parsing result is not a hash' do
    hash_parser.parser &lambda { |a,b,c| 5 }

    expect { hash_parser._parse(:first_name, nil) }
      .to raise_error(ArgumentError, "Result of HashParser  was 5 when it must be a hash.")
  end
end
