# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::StringParser do
  subject { described_class.parse(name, arg) }
  let(:name) { 'foo' }
  let(:arg) { 8 }

  describe '#parse' do
    it { is_expected.to match(name => '8') }
  end
end
