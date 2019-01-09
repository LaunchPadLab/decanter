# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::IntegerParser do
  subject { described_class.parse(arg) }

  describe '#parse' do
    context 'with an integer-like string ' do
      let(:arg) { '1' }
      it { is_expected.to eq 1 }
    end

    context 'with an float-like string ' do
      let(:arg) { '1.1' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with nil' do
      let(:arg) { nil }
      it { is_expected.to be_nil }
    end

    context 'with a duff string' do
      let(:arg) { 'abc' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
