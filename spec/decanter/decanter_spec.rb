require 'spec_helper'

describe Decanter do

  let(:foo) do
    Class.new do
      def self.name
        'Foo'
      end
    end
  end

  before(:each) { Decanter.class_variable_set(:@@decanters, {}) }
  after(:each) { Decanter.class_variable_set(:@@decanters, {}) }

  describe '#register' do

    it 'adds the class to the array of decanters' do
      Decanter.register(foo)
      expect(Decanter.class_variable_get(:@@decanters)).to match({'Foo' => foo})
    end
  end

  describe '#decanter_for' do

    context 'for a class' do

      context 'when a corresponding decanter does not exist' do
        it 'raises a name error' do
          expect { Decanter::decanter_for(foo) }
            .to raise_error(NameError, "unknown decanter FooDecanter")
        end
      end

      context 'when a corresponding decanter exists' do

        let(:foo_decanter) do
          Class.new do
            def self.name
              'FooDecanter'
            end
          end
        end

        before(:each) do
          Decanter.register(foo_decanter)
        end

        it 'returns the decanter' do
          expect(Decanter::decanter_for(foo)).to eq foo_decanter
        end
      end
    end

    context 'for a symbol' do

      context 'when a corresponding decanter does not exist' do
        it 'raises a name error' do
          expect { Decanter::decanter_for(:foo) }
            .to raise_error(NameError, "unknown decanter FooDecanter")
        end
      end

      context 'when a corresponding decanter exists' do

        let(:foo_decanter) do
          Class.new do
            def self.name
              'FooDecanter'
            end
          end
        end

        before(:each) do
          Decanter.register(foo_decanter)
        end

        it 'returns the decanter' do
          expect(Decanter::decanter_for(:foo)).to eq foo_decanter
        end
      end
    end
  end
end
