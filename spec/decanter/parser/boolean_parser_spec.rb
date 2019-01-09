# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::BooleanParser do
  subject { described_class.parse(arg) }

  describe '#parse' do
    trues = [
      ['integer', 1],
      ['boolean', true],
      %w(string 1),
      %w(string true),
      %w(string True),
      %w(string truE)
    ]

    falses = [
      ['integer', 0],
      ['integer', 2],
      ['boolean', false],
      %w(string 2),
      %w(string tru),
      %w(string false)
    ]

    trues.each do |kls, val|
      context "with a #{kls} of #{val.inspect}" do
        let(:arg) { val }
        it { is_expected.to be true }
      end
    end

    falses.each do |kls, val|
      context "with a #{kls} of #{val.inspect}" do
        let(:arg) { val }
        it { is_expected.to be false }
      end
    end
  end
end
