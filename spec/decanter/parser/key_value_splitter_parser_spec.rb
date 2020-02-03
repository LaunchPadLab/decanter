require 'spec_helper'

describe 'KeyValueSplitterParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::KeyValueSplitterParser }

  describe '#parse' do
    it 'returns an array with the split pairs' do
      expect(parser.parse(name, 'foo:bar,baz:foo')).to match({'foo' => 'bar', 'baz' => 'foo'})
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
  end
end
