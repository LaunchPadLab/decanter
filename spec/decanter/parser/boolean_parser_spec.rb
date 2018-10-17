# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::BooleanParser do
  subject { described_class.parse(name, arg) }
  let(:name) { 'foo' }

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

    let(:name) { :foo }

    trues.each do |kls, val|
      context "with a #{kls} of #{val.inspect}" do
        let(:arg) { val }
        it { is_expected.to match(name => true) }
      end
    end

    falses.each do |kls, val|
      context "with a #{kls} of #{val.inspect}" do
        let(:arg) { val }
        it { is_expected.to match(name => false) }
      end
    end
  end
end
