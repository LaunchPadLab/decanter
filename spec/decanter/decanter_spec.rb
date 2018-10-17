# frozen_string_literal: true

require 'spec_helper'

describe Decanter do
  before(:all) do
    Object.const_set('FooDecanter',
                     Class.new(Decanter::Base) do
                       def self.name
                         'FooDecanter'
                       end
                     end)
  end

  describe '#decanter_from' do
    context 'for a string' do
      context 'when a corresponding decanter exists' do
        let(:foo) { 'FooDecanter' }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(foo)).to eq FooDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:foo) { 'FoobarDecanter' }

        it 'raises a name error' do
          expect { Decanter.decanter_from(foo) }
            .to raise_error(NameError, "uninitialized constant #{foo}")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:foo) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(foo) }
            .to raise_error(ArgumentError, "#{foo.name} is not a decanter")
        end
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter exists' do
        let(:foo) { FooDecanter }

        it 'returns the decanter' do
          expect(Decanter.decanter_from(foo)).to eq FooDecanter
        end
      end

      context 'when a corresponding class does not exist' do
        let(:foo) { Class.new }

        it 'raises a name error' do
          expect { Decanter.decanter_from(foo) }
            .to raise_error(ArgumentError, "#{foo.name} is not a decanter")
        end
      end

      context 'when a corresponding class exists but it is not a decanter' do
        let(:foo) { String }

        it 'raises an argument error' do
          expect { Decanter.decanter_from(foo) }
            .to raise_error(ArgumentError, "#{foo.name} is not a decanter")
        end
      end
    end

    context 'for a symbol' do
      let(:foo) { :foo }

      it 'raises an argument error' do
        expect { Decanter.decanter_from(foo) }
          .to raise_error(ArgumentError, "cannot find decanter from #{foo} with class #{foo.class}")
      end
    end
  end

  describe '#decanter_for' do
    context 'for a string' do
      let(:foo) { 'Foo' }

      it 'raises an argument error' do
        expect { Decanter.decanter_for(foo) }
          .to raise_error(ArgumentError, "cannot lookup decanter for #{foo} with class #{foo.class}")
      end
    end

    context 'for a class' do
      context 'when a corresponding decanter does not exist' do
        let(:foo) do
          Class.new do
            def self.name
              'Foobar'
            end
          end
        end

        it 'raises a name error' do
          expect { Decanter.decanter_for(foo) }
            .to raise_error(NameError, "uninitialized constant #{foo.name.concat('Decanter')}")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:foo) do
          Class.new do
            def self.name
              'Foo'
            end
          end
        end

        it 'returns the decanter' do
          expect(Decanter.decanter_for(foo)).to eq FooDecanter
        end
      end
    end

    context 'for a symbol' do
      let(:foo) { :foobar }

      context 'when a corresponding decanter does not exist' do
        it 'raises a name error' do
          expect { Decanter.decanter_for(foo) }
            .to raise_error(NameError, "uninitialized constant #{foo.to_s.capitalize.concat('Decanter')}")
        end
      end

      context 'when a corresponding decanter exists' do
        let(:foo) { :foo }

        it 'returns the decanter' do
          expect(Decanter.decanter_for(foo)).to eq FooDecanter
        end
      end
    end
  end
end
