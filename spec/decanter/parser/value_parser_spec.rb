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

  it 'namespaces results with input name' do
    expect(parser.parse(:foo, 'bar')).to match({ foo: 'bar' })
  end

end
