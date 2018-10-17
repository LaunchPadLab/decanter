# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::FloatParser do
  subject { described_class.parse(name, arg) }
  let(:name) { :foo }

  describe '#parse' do
    context 'with an integer-like string ' do
      let(:arg) { '1' }
      it { is_expected.to match(name => 1.0) }
    end

    context 'with an float-like string ' do
      let(:arg) { '1.1' }
      it { is_expected.to match(name => 1.1) }
    end

    context 'with nil' do
      let(:arg) { nil }
      it { is_expected.to match(name => nil) }
    end

    context 'with a duff string' do
      let(:arg) { 'abc' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
