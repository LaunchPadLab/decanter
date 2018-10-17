# frozen_string_literal: true

module Decanter
  module Decant
    extend ActiveSupport::Concern

    def decant(decanter:, params:)
      Decanter.decanter_for(decanter).decant(params)
    end
  end
end
