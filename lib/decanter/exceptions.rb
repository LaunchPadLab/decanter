module Decanter
  class Error < StandardError; end
  class UnhandledKeysError < Error; end
  class MissingRequiredInputValue < Error; end
  class ParseError < Error; end
  class ValueFormatError < Error; end
end
