# frozen_string_literal: true

module Decanter
  class Error < StandardError; end
  class UnhandledKeysError < Error; end
  class MissingRequiredInputValue < Error; end
  class ParseError < Error; end
end
