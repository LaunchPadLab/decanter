# frozen_string_literal: true

require 'rails_helper'
require 'decanter/decant'

RSpec.describe Decanter::Decant, type: :controller do
  Object.const_set('FooDecanter',
                   Class.new(Decanter::Base) do
                     def self.name
                       'FooDecanter'
                     end
                   end)

  controller(ActionController::Base) do
    include Decanter::Decant

    def show
      decant(decanter: :foo, params: params)
      head :no_content
    end
  end

  before do
    routes.draw do
      get 'show' => 'anonymous#show'
    end
  end

  it do
    # stub call to #decant
    expect(FooDecanter).to receive(:decant).once
    get :show, params: { boolean: 'false' }
    expect(response.status).to eq 204
  end
end
