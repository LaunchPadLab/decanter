# frozen_string_literal: true

require 'spec_helper'

describe 'examples from the readme' do
  let(:trip) { Class.new(Decanter::Base) }

  subject { trip.decant(params) }

  before(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
    trip_inputs.each do |args|
      trip.input(*args)
    end
  end

  after(:each) do
    Decanter::Core.class_variable_set(:@@handlers, {})
    Decanter::Core.class_variable_set(:@@strict_mode, {})
  end

  let(:trip_inputs) do
    [%i(name string),
     %i(start_date date),
     %i(end_date date)]
  end

  describe 'example 1' do
    let(:params) do
      {
        name: 'My Trip',
        start_date: '15/01/2015',
        end_date: '20/01/2015'
      }
    end

    it { is_expected.to match(name: 'My Trip', start_date: Date.new(2015, 1, 15), end_date: Date.new(2015, 1, 20)) }
  end

  describe 'example 2' do
    let(:trip_inputs) do
      [
        %i(name string),
        [:start_date, :date, parse_format: '%Y-%m-%d'],
        [:end_date, :date, parse_format: '%Y-%m-%d']
      ]
    end

    let(:params) do
      {
        name: 'My Trip',
        start_date: '2015-01-15',
        end_date: '2015-01-20'
      }
    end

    it { is_expected.to match(name: 'My Trip', start_date: Date.new(2015, 1, 15), end_date: Date.new(2015, 1, 20)) }
  end

  describe 'example 3' do
    let(:destination) { DestinationDecanter = Class.new(Decanter::Base) }

    let(:trip_has_many) { [[:destinations]] }

    let(:destination_inputs) do
      [%i(city string),
       %i(state string),
       %i(arrival_date date),
       %i(departure_date date)]
    end

    let(:params) do
      {
        name: 'My Trip',
        start_date: '15/01/2015',
        end_date: '20/01/2015',
        destinations: [{
          city: 'Foo',
          state: 'Bar',
          arrival_date: '16/01/2015',
          departure_date: '18/01/2015'
        }]
      }
    end

    before do
      destination_inputs.each do |args|
        destination.input(*args)
      end

      trip_has_many.each do |args|
        trip.has_many(*args)
      end
    end

    it {
      is_expected.to match(
        name: 'My Trip',
        start_date: Date.new(2015, 1, 15),
        end_date: Date.new(2015, 1, 20),
        destinations: [
          { city: 'Foo', state: 'Bar', arrival_date: Date.new(2015, 1, 16), departure_date: Date.new(2015, 1, 18) }
        ]
      )
    }
  end

  describe 'Squashing inputs' do
    SquashDateParser = Class.new(Decanter::Parser::ValueParser) do
      parser do |values, _options|
        day, month, year = values.map(&:to_i)
        Date.new(year, month, day)
      end
    end

    let(:trip_inputs) { [[%i(day month year), :squash_date, key: :start_date]] }
    let(:params) { { day: 15, month: 1, year: 2015 } }

    it { is_expected.to match(start_date: Date.new(2015, 1, 15)) }
  end

  # chaining parsers done in decanter_core_spec

  describe 'No need for strong params' do
    let(:params) { { foo: 'bar', name: 'quux' } }
    let(:trip_inputs) { [:name] }

    before(:each) do
      trip.strict(strict)
    end

    describe 'mode: with exception' do
      let(:strict) { :with_exception }

      it { expect { subject }.to raise_error(Decanter::Core::UnhandledKeysError) }
    end

    describe 'mode: true' do
      let(:strict) { true }

      it { is_expected.to match(name: 'quux') }
    end

    describe 'mode: false' do
      let(:strict) { false }

      it { is_expected.to match(name: 'quux', foo: 'bar') }
    end
  end

  describe 'requiring params' do
    let(:trip_inputs) { [[:name, :string, required: true]] }

    describe 'with an empty param' do
      let(:params) { { name: '' } }
      it { expect { subject }.to raise_error(Decanter::Core::MissingRequiredInputValue) }
    end

    describe 'with a nil param' do
      let(:params) { { name: nil } }
      it { expect { subject }.to raise_error(Decanter::Core::MissingRequiredInputValue) }
    end

    describe 'with has_many' do
      let(:destination) { DestinationDecanter = Class.new(Decanter::Base) }
      let(:trip_inputs) { [%i(name)] }
      let(:params) { {name: 'foo'} }

      before do
        destination.input(:name, :string, required: true)
        trip.has_many(:destination, required: true)
      end

      it { expect { subject }.to raise_error(Decanter::Core::MissingRequiredInputValue) }

    end
  end
end
