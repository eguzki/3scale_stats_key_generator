require_relative('key_type')
require_relative('key_part')
require_relative('generators')
require_relative('key_formatters')

class KeyGenerator
  attr_reader :key_types, :job, :limits

  KEY_TYPE_IDX = :key_type_idx
  private_constant :KEY_TYPE_IDX

  KEY_IDX = :key_idx
  private_constant :KEY_IDX

  def initialize(key_types, job, limits = nil)
    @job = job
    @limits = limits
    @key_types = key_types
  end

  def keys
    generator.lazy.map { |key, _idx| key }
  end

  def indexes
    generator.lazy.map { |_key, idx| idx }
  end

  private

  def types_limits
    return [0, key_types.size - 1] if !limits

    # TODO Raise exception if some limits component is zero or return defaults???
    lim_start = limits[0][KEY_TYPE_IDX]
    lim_end = limits[1][KEY_TYPE_IDX]
    [lim_start, lim_end]
  end

  def keyparts_limits(key_type_idx)
    return nil if limits.nil?

    lim_start = limits[0][KEY_IDX] if key_type_idx == limits[0][KEY_TYPE_IDX]

    lim_finish = limits[1][KEY_IDX] if key_type_idx == limits[1][KEY_TYPE_IDX]

    [lim_start, lim_finish]
  end

  def generator
    type_lim_start, type_lim_end = types_limits
    Enumerator.new do |yielder|
      key_types[type_lim_start..type_lim_end].to_enum.with_index(type_lim_start) do |key_type, key_type_idx|
        key_type.generator(keyparts_limits(key_type_idx)).each do |key, key_idx|
          yielder << [key, { KEY_TYPE_IDX => key_type_idx, KEY_IDX => key_idx }]
        end
      end
    end
  end
end
