# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::KeyValueSplitterParser do
  subject { described_class.parse(name, arg, opts) }
  let(:name) { 'foo' }
  let(:opts) { {} }

  describe '#parse' do
    let(:arg) { 'foo:bar,baz:quux' }
    it { is_expected.to match(name => { 'foo' => 'bar', 'baz' => 'quux' }) }

    context 'with the delimter option specified' do
      let(:arg) { 'fooXbarYbazXquux' }
      let(:opts) { { item_delimiter: 'Y', pair_delimiter: 'X' } }

      it { is_expected.to match(name => { 'foo' => 'bar', 'baz' => 'quux' }) }
    end
  end
end
