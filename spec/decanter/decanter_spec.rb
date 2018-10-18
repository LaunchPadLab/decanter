# frozen_string_literal: true

require 'spec_helper'

describe Decanter do
  DecanterSpecDecanter = Class.new(Decanter::Base) do
    def self.name
      'DecanterSpecDecanter'
    end
  end

  describe '#decanter_from' do
    context 'for a string' do
      context 'when a corresponding decanter exists' do
        let(:the_decanter) { 'DecanterSpecDecanter' }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(the_decanter)).to eq DecanterSpecDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:the_decanter) { 'DecanterbarDecanter' }

        it 'raises a name error' do
          expect { Decanter.decanter_from(the_decanter) }
            .to raise_error(NameError, "uninitialized constant #{the_decanter}")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:the_decanter) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(the_decanter) }
            .to raise_error(ArgumentError, "#{the_decanter.name} is not a decanter")
        end
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter exists' do
        let(:the_decanter) { DecanterSpecDecanter }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(the_decanter)).to eq DecanterSpecDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:the_decanter) { Class.new }

        it 'raises a name error' do
          expect { Decanter.decanter_from(the_decanter) }
            .to raise_error(ArgumentError, "#{the_decanter.name} is not a decanter")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:the_decanter) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(the_decanter) }
            .to raise_error(ArgumentError, "#{the_decanter.name} is not a decanter")
        end
      end
    end

    context 'for a symbol' do
      let(:the_decanter) { :decanter_spec }

      it 'raises an argument error' do
        expect { Decanter.decanter_from(the_decanter) }
          .to raise_error(ArgumentError, "cannot find decanter from #{the_decanter} with class #{the_decanter.class}")
      end
    end
  end

  describe '#decanter_for' do
    context 'for a string' do
      let(:the_decanter) { 'DecanterSpec' }

      it 'raises an argument error' do
        expect { Decanter.decanter_for(the_decanter) }
          .to raise_error(ArgumentError, "cannot lookup decanter for #{the_decanter} with class #{the_decanter.class}")
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter does not exist' do
        let(:the_decanter) do
          Class.new do
            def self.name
              'Decanterbar'
            end
          end
        end

        it 'raises a name error' do
          expect { Decanter.decanter_for(the_decanter) }
            .to raise_error(NameError, "uninitialized constant #{the_decanter.name}Decanter")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:the_decanter) do
          Class.new do
            def self.name
              'DecanterSpec'
            end
          end
        end

        it 'returns the decanter' do
          expect(Decanter.decanter_for(the_decanter)).to eq DecanterSpecDecanter
        end
      end
    end

    context 'for a symbol' do
      let(:the_decanter) { :foobar }

      context 'when a corresponding decanter does not exist' do
        it 'raises a name error' do
          expect { Decanter.decanter_for(the_decanter) }
            .to raise_error(NameError, "uninitialized constant #{the_decanter.to_s.capitalize.concat('Decanter')}")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:the_decanter) { :decanter_spec }

        it 'returns the decanter' do
          expect(Decanter.decanter_for(the_decanter)).to eq DecanterSpecDecanter
        end
      end
    end
  end
end
