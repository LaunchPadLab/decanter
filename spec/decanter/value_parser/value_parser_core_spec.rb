require 'spec_helper'

describe 'Core' do

  let(:core) { Class.new { include Decanter::ValueParser::Core } }

  describe '#parser' do
    it 'sets class variable @parser to equal the block' do
      parser = Proc.new {}
      core.parser &parser
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

      context 'when required' do

        it 'raises an argument error' do
          expect { core.parse('first_name', nil, required: true) }
            .to raise_error(ArgumentError, 'No value for required argument: first_name')
        end
      end

      context 'when not required' do

        it 'returns the value' do
          expect(core.parse('first_name', nil, required: false)).to match(['first_name', nil])
        end
      end
    end

    context 'for non-blank value' do

      let(:parser) { Proc.new {} }

      before(:each) do
        allow(parser).to receive(:call)
        core.allow String
      end

      context 'when type is allowed' do

        it 'returns the value' do
          expect(core.parse('first_name', 'foo')).to match(['first_name', 'foo'])
        end

        it 'does not call the parser' do
          core.parser &parser
          core.parse('first_name', 'foo')
          expect(parser).to_not have_received(:call)
        end
      end

      context 'when type is not allowed' do

        context 'when a parser is defined' do

          it 'calls the parser' do
            core.parser &parser
            core.parse('first_name', 5, required: true)
            expect(parser)
              .to have_received(:call)
              .with('first_name', 5, required: true)
          end
        end

        context 'when a parser is not defined' do
          it 'raises an ArgmentError' do
            expect { core.parse('first_name', 5, required: true) }
              .to raise_error(ArgumentError, "No parser for argument: first_name with type: #{5.class}")
          end
        end
      end
    end
  end
end
