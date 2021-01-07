require 'spec_helper'

describe Decanter::CollectionDetection do
  let(:base_decanter) {
    stub_const('BaseDecanter', Class.new)
  }

  let(:decanter) {
    stub_const('TripDecanter', base_decanter.new)
    TripDecanter.class_eval { include Decanter::CollectionDetection }
  }
  let(:args) { { destination: 'Hawaii' } }

  before(:each) {
    allow(base_decanter).to receive(:decant)
  }

  describe '#decant' do
    context 'when args are a single hash' do
      it 'calls decant on the entire element' do
        decanter.decant(args)
        expect(base_decanter).to have_received(:decant).once.with(args)
      end
    end

    context 'when no collection option is passed' do
      context 'and args are a collection' do
        let(:args) { [{ destination: 'Hawaii' }, { destination: 'Denver' }] }

        it 'calls decant with each element' do
          decanter.decant(args)
          expect(base_decanter).to have_received(:decant).with(args.first)
          expect(base_decanter).to have_received(:decant).with(args.second)
        end
      end

      context 'and args are not a collection' do
        let(:args) { { "0": [{ destination: 'Hawaii' }] } }
        it 'calls decant on the entire element' do
          decanter.decant(args)
          expect(base_decanter).to have_received(:decant).once.with(args)
        end
      end
    end

    context 'when the collection option is passed' do
      let(:fake_collection) { double('fake_collection') }
      let(:args) { fake_collection }

      before(:each) do
        allow(fake_collection).to receive(:map).and_yield(1).and_yield(2)
      end

      context 'and the value is true' do
        it 'is considered a collection' do
          decanter.decant(args, is_collection: true)
          expect(base_decanter).to have_received(:decant).with(1)
          expect(base_decanter).to have_received(:decant).with(2)
        end
      end

      context 'and the value is false' do
        it 'is not considered a collection' do
          decanter.decant(args, is_collection: false)
          expect(base_decanter).to have_received(:decant).once.with(args)
        end
      end

      context 'and the value is truthy' do
        it 'is not considered a collection' do
          decanter.decant(args, is_collection: 'yes')
          expect(base_decanter).to have_received(:decant).once.with(args)
        end
      end
    end
  end
end
