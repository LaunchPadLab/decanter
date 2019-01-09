# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::TimeParser do
  subject { described_class.parse(arg, opts) }
  let(:opts) { {} }

  describe '#parse' do
    context 'with a valid parseable time string' do
      let(:arg) { '21/2/1990 04:15:16 PM' }
      it { is_expected.to eq Time.new(1990, 2, 21, 16, 15, 16) }
    end

    context 'with an invalid string' do
      let(:arg) { 'this is not a date' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with nil' do
      let(:arg) { nil }
      it { is_expected.to be_nil }
    end

    context 'with a Time' do
      let(:arg) { Time.new(1990, 2, 21) }
      it { is_expected.to eq Time.new(1990, 2, 21) }
    end

    # rubocop:disable Style/DateTime
    context 'with a DateTime' do
      let(:arg) { DateTime.new(1990, 2, 21) }
      it { is_expected.to eq Time.new(1990, 2, 21) }
    end
    # rubocop:enable Style/DateTime

    context 'with a valid date string and custom format' do
      let(:arg) { '2-21-1990' }
      let(:opts) { { parse_format: '%m-%d-%Y' } }
      it { is_expected.to eq Time.new(1990, 2, 21) }
    end
  end
end
