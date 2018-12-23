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

  def initialize(key_types, job:, limits: nil)
    @job = job
    @limits = limits
    @key_types = key_types
  end

  def keys
    generator.lazy.map { |key, _idx| key }
  end

  ##
  # index Format:
  # Hash value:
  # {
  #   :key_type_idx=>0,
  #   :key_idx=> {
  #     KEY_PART_ID_0=>{:generator_index=>GEN_IDX, :idx=>IDX},
  #     KEY_PART_ID_1=>{:generator_index=>GEN_IDX, :idx=>IDX},
  #     ...
  #     KEY_PART_ID_N-1=>{:generator_index=>GEN_IDX, :idx=>IDX},
  #   }
  # }
  def indexes
    generator.lazy.map { |_key, idx| idx }
  end

  private

  def types_limits
    return [0, key_types.size - 1] if limits.nil?

    lim_start = limits[0][KEY_TYPE_IDX]
    lim_end = limits[1][KEY_TYPE_IDX]
    [lim_start, lim_end]
  end

  def type_limits(key_type_idx)
    return nil if limits.nil?

    lim_start = limits[0][KEY_IDX] if key_type_idx == limits[0][KEY_TYPE_IDX]

    lim_finish = limits[1][KEY_IDX] if key_type_idx == limits[1][KEY_TYPE_IDX]

    [lim_start, lim_finish]
  end

  def generator
    type_lim_start, type_lim_end = types_limits
    Enumerator.new do |yielder|
      key_types[type_lim_start..type_lim_end].to_enum.with_index(type_lim_start) do |key_type, key_type_idx|
        a = 0
        key_type.generator(job: job, limits: type_limits(key_type_idx)).each do |key, key_idx|
          yielder << [key, { KEY_TYPE_IDX => key_type_idx, KEY_IDX => key_idx }]
          puts "a = #{a}"
          a += 1
        end
      end
    end
  end
end
