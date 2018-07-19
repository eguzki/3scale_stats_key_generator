require_relative('serialize')

class KeyIndex
  include Serialize
  ATTRIBUTES = %i[key_type metric app user granularity ts].freeze
  private_constant :ATTRIBUTES
  attr_accessor(*ATTRIBUTES)
end
