# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Style/DateTime
describe Decanter::Parser::DateTimeParser do
  subject { described_class.parse(name, arg, opts) }
  let(:name) { :foo }
  let(:opts) { {} }

  describe '#parse' do
    context 'with a parseable date-time string' do
      let(:arg) { '21/2/1990 04:15:16 PM' }
      it { is_expected.to match(name => DateTime.new(1990, 2, 21, 16, 15, 16)) }
    end

    context 'with an invalid string' do
      let(:arg) { 'this is not a date' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with nil' do
      let(:arg) { nil }
      it { is_expected.to match(name => nil) }
    end

    context 'with a Time' do
      let(:arg) { Time.new(1990, 2, 21) }
      it { is_expected.to match(name => DateTime.new(1990, 2, 21)) }
    end

    context 'with a DateTime' do
      let(:arg) { DateTime.new(1990, 2, 21) }
      it { is_expected.to match(name => DateTime.new(1990, 2, 21)) }
    end

    context 'with a valid date string and custom format' do
      let(:arg) { '2-21-1990' }
      let(:opts) { { parse_format: '%m-%d-%Y' } }
      it { is_expected.to match(name => DateTime.new(1990, 2, 21)) }
    end
  end
end
