require 'spec_helper'

describe Decanter::Extensions do

  let(:dummy_class)    { Class.new { include Decanter::Extensions } }
  let(:dummy_instance) { dummy_class.new }

  before(:each) do
    allow(dummy_class).to receive(:new).and_return(dummy_instance)
    allow(dummy_class).to receive(:decant) { |args, context| args }
    allow(dummy_instance).to receive(:attributes=)
    allow(dummy_instance).to receive(:save)
    allow(dummy_instance).to receive(:save!)
    # allow(dummy_instance).to receive(:decant) { |args, context| args }
  end

  shared_examples 'a decanter update' do |strict|

    let(:args) { { foo: 'bar' } }

    context 'with no context' do

      before(:each) { strict ?
                        dummy_instance.decant_update!(args) :
                        dummy_instance.decant_update(args)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy_instance).to have_received(:attributes=).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model" do
        expect(dummy_instance).to have_received( strict ? :save! : :save )
      end
    end

    context 'with context' do

      let(:_context) { :foo }

      before(:each) { strict ?
                        dummy_instance.decant_update!(args, _context) :
                        dummy_instance.decant_update(args, _context)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy_instance).to have_received(:attributes=).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model with the context" do
        expect(dummy_instance)
          .to have_received(strict ? :save! : :save)
          .with(context: _context)
      end
    end
  end

  shared_examples 'a decanter create' do |strict|

    let(:args) { { foo: 'bar' } }

    context 'with no context' do

      before(:each) { strict ?
                        dummy_class.decant_create!(args) :
                        dummy_class.decant_create(args)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy_class).to have_received(:new).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model" do
        expect(dummy_instance).to have_received( strict ? :save! : :save )
      end
    end

    context 'with context' do

      let(:_context) { :foo }

      before(:each) { strict ?
                        dummy_class.decant_create!(args, _context) :
                        dummy_class.decant_create(args, _context)
      }

      it 'sets the attributes on the model with the results from the decanter' do
        expect(dummy_class).to have_received(:new).with(args)
      end

      it "calls #{strict ? 'save!' : 'save'} on the model with the context" do
        expect(dummy_instance)
          .to have_received(strict ? :save! : :save)
          .with(context: _context)
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
