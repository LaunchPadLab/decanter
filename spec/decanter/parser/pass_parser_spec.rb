# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::PassParser do
  subject { described_class.parse(arg) }
  let(:arg) { '(12)2-21/19.90' }

  describe '#parse' do
    it { is_expected.to eq arg }
  end
end
