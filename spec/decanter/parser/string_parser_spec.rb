# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::StringParser do
  subject { described_class.parse(arg) }
  let(:arg) { 8 }

  describe '#parse' do
    it { is_expected.to eq '8' }
  end
end
