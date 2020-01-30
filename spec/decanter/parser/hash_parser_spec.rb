require 'spec_helper'

describe 'HashParser' do

  let(:parser) { 
    # Mock parser just passes value through
    Class.new(Decanter::Parser::HashParser) do
      parser do |_name, val, _options|
        val
      end
    end
  }

  it 'does not namespace results' do
    expect(parser.parse(:first_name, { foo: 'bar' })).to eq({ foo: 'bar' })
  end

  context 'when the result is not a hash' do
    let(:parser) { 
      # Mock parser just passes value through
      Class.new(Decanter::Parser::HashParser) do
        parser do |_name, val, _options|
          val
        end
      end
    }
    it 'raises an argument error' do
      expect { parser.parse(:first_name, 'bar') }
        .to raise_error(ArgumentError, "Result of HashParser  was bar when it must be a hash.")
    end
  end
end
