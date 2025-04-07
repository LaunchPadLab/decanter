# frozen_string_literal: true

require 'spec_helper'

describe 'HashParser' do
  let(:parser) do
    # Mock parser just passes value through
    Class.new(Decanter::Parser::HashParser) do
      parser do |_name, val, _options|
        val
      end
    end
  end

  context 'when the result is a hash' do
    it 'returns the hash directly' do
      expect(parser.parse(:first_name, { foo: 'bar' })).to eq({ foo: 'bar' })
    end
  end

  context 'when the result is not a hash' do
    it 'raises an argument error' do
      expect { parser.parse(:first_name, 'bar') }
        .to raise_error(ArgumentError, 'Result of HashParser  was bar when it must be a hash.')
    end
  end
end
