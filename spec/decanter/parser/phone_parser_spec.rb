# frozen_string_literal: true

require 'spec_helper'

describe Decanter::Parser::PhoneParser do
  subject { described_class.parse(name, arg) }
  let(:name) { 'foo' }
  let(:arg) { '(12)2-21/19.90' }

  describe '#parse' do
    it 'strips out all non-numeric bits' do
      is_expected.to match(name => '122211990')
    end
  end
end
