# frozen_string_literal: true

require 'rails_helper'
require 'decanter/decant'

RSpec.describe Decanter::Decant, type: :controller do
  before(:all) do
    FooDecanter = Class.new(Decanter::Base) do
      def self.name
        'FooDecanter'
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, 'FooDecanter')
  end

  controller(ActionController::Base) do
    include Decanter::Decant

    def show
      decant(:foo, params)
      head :no_content
    end
  end

  before do
    routes.draw do
      get 'show' => 'anonymous#show'
    end
  end

  let(:params) { { boolean: false } }

  it do
    # stub call to #decant
    expect(FooDecanter).to receive(:decant).once
    get :show, params: params
    expect(response.status).to eq 204
  end
end
