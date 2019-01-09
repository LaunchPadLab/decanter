# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::Core do
  let(:core) { Class.new { include Decanter::Parser::Core } }

  describe '#parser' do
    it 'sets class variable @parser to equal the block' do
      parser = proc {}
      core.parser(&parser)
      expect(core.instance_variable_get(:@parser)).to eq parser
    end
  end

  describe '#allow' do
    it 'adds the constantized values to the allowed pass through types' do
      core.allow Date, TrueClass, FalseClass
      expect(core.instance_variable_get(:@allowed)).to match([Date, TrueClass, FalseClass])
    end
  end

  describe '#parse' do
    context 'for blank value' do
      it 'returns the value' do
        expect(core.parse(nil)).to be_nil
      end
    end

    context 'for empty string' do
      it 'returns nil' do
        expect(core.parse('')).to be_nil
      end
    end

    context 'for non-blank value' do
      let(:parser) { proc {} }

      before(:each) do
        allow(parser).to receive(:call)
        core.allow String
      end

      context 'when type is allowed' do
        it 'returns the value' do
          expect(core.parse('foo')).to eq 'foo'
        end

        it 'does not call the parser' do
          allow(core).to receive(:_parse)
          core.parser(&parser)
          core.parse('first_name', ['foo'])
          expect(core).to_not have_received(:_parse)
        end
      end

      context 'when type is not allowed' do
        context 'when a parser is defined' do
          it 'calls the parser' do
            allow(core).to receive(:_parse)
            core.parser(&parser)
            core.parse(5, required: true)
            expect(core)
              .to have_received(:_parse)
              .with(5, required: true)
          end
        end
      end
    end
  end
end
