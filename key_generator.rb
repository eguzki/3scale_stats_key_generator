require_relative('key_type')
require_relative('key_part')
require_relative('generators')
require_relative('key_formatters')

class KeyGenerator
  attr_reader :key_types

  def initialize(key_types)
    @key_types = key_types
  end

  def keys
    Enumerator.new do |yielder|
      key_types.each do |key_type|
        key_type.generator.each do |key|
          yielder << key
        end
      end
    end
  end
end
