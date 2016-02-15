require 'spec_helper'

describe 'KeyValueSplitterParser' do

  let(:parser) { Decanter::ValueParser::KeyValueSplitterParser }

  describe '#parse' do
    it 'returns an array with the split pairs' do
      expect(parser.parse('foo', 'foo:bar,baz:foo')).to match [['foo', 'bar'], ['baz', 'foo']]
    end
  end
end
