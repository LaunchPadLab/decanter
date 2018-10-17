require 'spec_helper'

describe 'PassParser' do
  let(:parser) { Decanter::Parser::PassParser }

  describe '#parse' do
    it 'lets anything through' do
      expect(parser.parse(:foo, '(12)2-21/19.90')).to match(foo: '(12)2-21/19.90')
    end
  end
end
