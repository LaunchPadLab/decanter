require 'spec_helper'

describe Decanter::Extensions do

  describe '#decant' do
    let(:options) { { } }
    let(:dummy_class) { Class.new { include Decanter::Extensions } }

    context 'when args is a single resource' do
      let(:args) { { } }

      before(:each) do
        allow(dummy_class).to receive(:decant_args).and_return(true)
      end

      it 'calls decant_args with the args and options' do
        dummy_class.decant(args, options)
        expect(dummy_class)
          .to have_received(:decant_args)
          .with(args, options)
      end
    end

    context 'when args is a collection' do
      let(:args) { [{}, {}] }

      before(:each) do
        allow(dummy_class).to receive(:decant_collection).and_return(true)
      end

      it 'calls decant_collection with the args and options' do
        dummy_class.decant(args, options)
        expect(dummy_class)
          .to have_received(:decant_collection)
          .with(args, options)
      end
    end
  end

  describe '#decant_collection' do
    let!(:args) { [{ foo: 'bar' }, { foo: 'baz' }] }
    let(:options) { { } }
    let(:dummy_class) { Class.new { include Decanter::Extensions } }

    before(:each) do
      allow(dummy_class).to receive(:decant_args).and_return(true)
    end

    it 'calls decant_args on each element in the collection' do
      # expect(dummy_class).to receive(:decant_args).twice
      dummy_class.decant_collection(args, options)
      expect(dummy_class)
        .to have_received(:decant_args)
        .with(args[0], options)
      expect(dummy_class)
        .to have_received(:decant_args)
        .with(args[1], options)
    end
  end

  describe '#decant_args' do
    let(:args) { { } }
    let(:decanter) { class_double('Decanter::Base', decant: true) }

    context 'when a decanter is specified' do
      let(:options) { { decanter: 'FooDecanter' } }

      before(:each) do
        allow(Decanter).to receive(:decanter_from).and_return(decanter)
      end

      it 'calls Decanter.decanter_from with the specified decanter' do
        dummy_class = Class.new { include Decanter::Extensions }
        dummy_class.decant_args(args, options)
        expect(Decanter)
          .to have_received(:decanter_from)
          .with(options[:decanter])
      end

      it 'calls decant on the returned decanter with the args' do
        dummy_class = Class.new { include Decanter::Extensions }
        dummy_class.decant_args(args, options)
        expect(decanter)
          .to have_received(:decant)
          .with(args)
      end
    end

    context 'when the decanter is not specified' do
      let(:options) { { } }

      before(:each) do
        allow(Decanter).to receive(:decanter_for).and_return(decanter)
      end

      it 'calls Decanter.decanter_for with self' do
        dummy_class = Class.new { include Decanter::Extensions }
        dummy_class.decant_args(args, options)
        expect(Decanter)
          .to have_received(:decanter_for)
          .with(dummy_class)
      end

      it 'calls decant on the returned decanter with the args' do
        dummy_class = Class.new { include Decanter::Extensions }
        dummy_class.decant_args(args, options)
        expect(decanter)
          .to have_received(:decant)
          .with(args)
      end
    end
  end

  describe '#is_collection?' do
    let(:singular_args) { { foo: 'bar' } }
    let(:collection_args) { [{ foo: 'bar' }, { foo: 'baz' }] }
    let(:dummy_class) { Class.new { include Decanter::Extensions } }

    context 'true' do
      it 'when options[:is_collection] is nil and collection is provided' do
        expect(dummy_class.is_collection?(collection_args)).to be(true)
      end

      it 'when options[:is_collection] is true' do
        expect(dummy_class.is_collection?(singular_args, { is_collection: true })).to be(true)
      end
    end

    context 'false' do
      it 'when options[:is_collection] is nil and single object is provided' do
        expect(dummy_class.is_collection?(singular_args)).to be(false)
      end

       it 'when options[:is_collection] is false' do
        expect(dummy_class.is_collection?(collection_args, { is_collection: false })).to be(false)
      end
    end
  end

  context '' do
    let(:dummy_class)    { Class.new { include Decanter::Extensions } }
    let(:dummy_instance) { dummy_class.new }

    before(:each) do
      allow(dummy_class).to receive(:new).and_return(dummy_instance)
      allow(dummy_class).to receive(:decant) { |args| args }
      allow(dummy_instance).to receive(:attributes=)
      allow(dummy_instance).to receive(:save)
      allow(dummy_instance).to receive(:save!)
    end

    shared_examples 'a decanter update' do |strict|
      let(:args) { { foo: 'bar' } }

      before(:each) { strict ? dummy_instance.decant_update!(args) : dummy_instance.decant_update(args) }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy_instance).to have_received(:attributes=).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model" do
        expect(dummy_instance).to have_received( strict ? :save! : :save )
      end
    end

    shared_examples 'a decanter create' do |strict|
      let(:args) { { foo: 'bar' } }

      context 'with no context' do
        before(:each) { strict ? dummy_class.decant_create!(args) : dummy_class.decant_create(args) }

        it 'sets the attributes on the model with the results from the decanter' do
          expect(dummy_class).to have_received(:new).with(args)
        end

        it "calls #{strict ? 'save!' : 'save'} on the model" do
          expect(dummy_instance).to have_received( strict ? :save! : :save )
        end
      end
    end

    describe '#decant_update' do
      it_behaves_like 'a decanter update'
    end

    describe '#decant_update!' do
      it_behaves_like 'a decanter update', true
    end

    describe '#decant_create' do
      it_behaves_like 'a decanter create'
    end

    describe '#decant_create!' do
      it_behaves_like 'a decanter create', true
    end
  end
end
