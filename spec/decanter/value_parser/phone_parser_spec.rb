require 'spec_helper'

describe 'PhoneParser' do

  let(:parser) { Decanter::ValueParser::PhoneParser }

  describe '#parse' do
    it 'strips all non-numbers from value and returns a string' do
      expect(parser.parse(:foo, '(12)2-21/19.90')).to match([:foo,'122211990'])
    end
  end
end
