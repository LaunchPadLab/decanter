require 'spec_helper'

describe 'ValueParser' do

  let(:parser) { 
    # Mock parser just passes value through
    Class.new(Decanter::Parser::ValueParser) do
      parser do |val, _options|
        val
      end
    end
  }

  context 'when the result is a single value' do
    it 'returns a hash with the value keyed under the name' do
      expect(parser.parse(:foo, 'bar')).to match({ foo: 'bar' })
    end
  end

end
