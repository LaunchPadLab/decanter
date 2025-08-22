require 'spec_helper'

describe 'JsonParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::JsonParser }

  describe '#parse' do
    it 'parses string value and returns a parsed JSON' do
      expect(parser.parse(name, '{"key": "value"}')).to match({name => {"key" => "value"}})
    end

    context 'with empty string' do
      it 'returns nil' do
        expect(parser.parse(name, '')).to match({name => nil})
      end
    end

    context 'with nil' do
      it 'returns nil' do
        expect(parser.parse(name, nil)).to match({name => nil})
      end
    end

    context 'when provided with an invalid JSON string' do
      it 'raises a Decanter::ParseError' do
        expect { parser.parse(name, 'invalid') }.to raise_error(Decanter::ParseError)
      end
    end
  end
end
