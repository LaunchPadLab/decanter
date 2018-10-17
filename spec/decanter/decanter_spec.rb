# frozen_string_literal: true

require 'spec_helper'

describe Decanter do
  DecanterDecanter = Class.new(Decanter::Base) do
    def self.name
      'DecanterDecanter'
    end
  end

  describe '#decanter_from' do
    context 'for a string' do
      context 'when a corresponding decanter exists' do
        let(:decanter) { 'DecanterDecanter' }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(decanter)).to eq DecanterDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:decanter) { 'DecanterbarDecanter' }

        it 'raises a name error' do
          expect { Decanter.decanter_from(decanter) }
            .to raise_error(NameError, "uninitialized constant #{decanter}")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:decanter) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(decanter) }
            .to raise_error(ArgumentError, "#{decanter.name} is not a decanter")
        end
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter exists' do
        let(:decanter) { DecanterDecanter }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(decanter)).to eq DecanterDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:decanter) { Class.new }

        it 'raises a name error' do
          expect { Decanter.decanter_from(decanter) }
            .to raise_error(ArgumentError, "#{decanter.name} is not a decanter")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:decanter) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(decanter) }
            .to raise_error(ArgumentError, "#{decanter.name} is not a decanter")
        end
      end
    end

    context 'for a symbol' do
      let(:decanter) { :decanter }

      it 'raises an argument error' do
        expect { Decanter.decanter_from(decanter) }
          .to raise_error(ArgumentError, "cannot find decanter from #{decanter} with class #{decanter.class}")
      end
    end
  end

  describe '#decanter_for' do
    context 'for a string' do
      let(:decanter) { 'Decanter' }

      it 'raises an argument error' do
        expect { Decanter.decanter_for(decanter) }
          .to raise_error(ArgumentError, "cannot lookup decanter for #{decanter} with class #{decanter.class}")
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter does not exist' do
        let(:decanter) do
          Class.new do
            def self.name
              'Decanterbar'
            end
          end
        end

        it 'raises a name error' do
          expect { Decanter.decanter_for(decanter) }
            .to raise_error(NameError, "uninitialized constant #{decanter.name}Decanter")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:decanter) do
          Class.new do
            def self.name
              'Decanter'
            end
          end
        end

        it 'returns the decanter' do
          expect(Decanter.decanter_for(decanter)).to eq DecanterDecanter
        end
      end
    end

    context 'for a symbol' do
      let(:decanter) { :foobar }

      context 'when a corresponding decanter does not exist' do
        it 'raises a name error' do
          expect { Decanter.decanter_for(decanter) }
            .to raise_error(NameError, "uninitialized constant #{decanter.to_s.capitalize.concat('Decanter')}")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:decanter) { :decanter }

        it 'returns the decanter' do
          expect(Decanter.decanter_for(decanter)).to eq DecanterDecanter
        end
      end
    end
  end
end
