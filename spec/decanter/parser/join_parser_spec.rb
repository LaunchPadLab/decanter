# frozen_string_literal: true

require 'spec_helper'

describe 'JoinParser' do
  let(:parser) { Decanter::Parser::JoinParser }

  describe '#parse' do
    let(:args) { ['foo', %w(foo bar)] }
    it 'returns a string joined with commas' do
      expect(parser.parse(*args)).to match('foo' => 'foo,bar')
    end

    context 'with the delimter option specified' do
      let(:delimiter) { ':' }

      it 'returns a string joined with colons' do
        expect(parser.parse(*args, delimiter: delimiter)).to match('foo' => 'foo:bar')
      end
    end
  end
end
