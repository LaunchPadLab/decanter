require 'decanter/core'
require 'decanter/collection_detection'

module Decanter
  class Base
    include Core
    include CollectionDetection
  end
end
