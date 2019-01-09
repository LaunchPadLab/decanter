# frozen_string_literal: true

module Decanter
  module Core
    class Error < StandardError; end
    class UnhandledKeysError < Error; end
    class MissingRequiredInputValue < Error; end
  end
end
