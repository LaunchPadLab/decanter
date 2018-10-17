# frozen_string_literal: true

require 'spec_helper'

describe 'IntegerParser' do
  let(:name) { :foo }

  let(:parser) { Decanter::Parser::IntegerParser }

  describe '#parse' do
    context 'with an integer-like string ' do
      it do
        expect(parser.parse(name, '1')).to match(name => 1)
      end
    end

    context 'with an float-like string ' do
      it do
        expect { parser.parse(name, '1.1') }.to raise_error(ArgumentError)
      end
    end

    context 'with nil' do
      it do
        expect(parser.parse(name, nil)).to match(name => nil)
      end
    end

    context 'with a duff string' do
      it do
        expect { parser.parse(name, 'abc') }.to raise_error(ArgumentError)
      end
    end
  end
end
