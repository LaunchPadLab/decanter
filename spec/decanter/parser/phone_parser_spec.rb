require 'spec_helper'

describe 'PhoneParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::PhoneParser }

  describe '#parse' do
    it 'strips all non-numbers from value and returns a string' do
      expect(parser.parse(:foo, '(12)2-21/19.90')).to match({:foo =>'122211990'})
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
