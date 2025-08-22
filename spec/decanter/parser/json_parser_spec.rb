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

    context 'with a non-string value' do
      it 'raises a Decanter::ParseError' do
        expect { parser.parse(name, 1) }.to raise_error(Decanter::ParseError, 'Expects a JSON string')
        expect { parser.parse(name, true) }.to raise_error(Decanter::ParseError, 'Expects a JSON string')
      end
    end

    context 'with string that is invalid JSON' do
      json_parser_error = 'Invalid JSON string'
      it 'raises a Decanter::ParseError' do
        expect { parser.parse(name, 'invalid') }.to raise_error(Decanter::ParseError, json_parser_error)
        expect { parser.parse(name, '{ name: "John Smith", age: 30 }') }.to raise_error(Decanter::ParseError, json_parser_error)
        expect { parser.parse(name, '{\"bio\": \"Line1 \n Line2\"}') }.to raise_error(Decanter::ParseError, json_parser_error)
        expect { parser.parse(name, '{ "name": "John Smith", "age": 30, }') }.to raise_error(Decanter::ParseError, json_parser_error)
      end
    end
  end
end
