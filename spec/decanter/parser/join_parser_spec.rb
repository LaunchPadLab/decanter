# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::JoinParser do
  subject { described_class.parse(arg, opts) }
  let(:opts) { {} }

  describe '#parse' do
    let(:arg) { %w(foo bar) }
    it { is_expected.to eq 'foo,bar' }

    context 'with the delimter option specified' do
      let(:opts) { { delimiter: ':' } }

      it { is_expected.to eq 'foo:bar' }
    end
  end
end
