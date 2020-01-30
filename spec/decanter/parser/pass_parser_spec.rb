require 'spec_helper'

describe 'PassParser' do

  let(:name) { :foo }

  let(:parser) { Decanter::Parser::PassParser }

  describe '#parse' do
    it 'lets anything through' do
      expect(parser.parse(name, '(12)2-21/19.90')).to match({name =>'(12)2-21/19.90'})
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
