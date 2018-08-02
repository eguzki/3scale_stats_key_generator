#!/usr/bin/env ruby

class StatsKeyGenerator
  attr_reader :types

  TYPE_IDX_FIELD_NAME = :type
  private_constant :TYPE_IDX_FIELD_NAME

  TYPE_KEY_PARTS_NAME = :key_part
  private_constant :TYPE_KEY_PARTS_NAME

  def initialize
    @types = []
  end

  def <<(type)
    types << type
  end

  def get_types_limits(limits)
    return [0, types.size - 1] if !limits
    # TODO Raise exception if some limits component is zero or return defaults???
    lim_start = limits[0][TYPE_IDX_FIELD_NAME]
    lim_end = limits[1][TYPE_IDX_FIELD_NAME]
    [lim_start, lim_end]
  end

  def generator(limits = nil)
    type_lim_start, type_lim_end = get_types_limits(limits)
    Enumerator.new do |yielder|
      #TODO what happens with the results if no contents are generated???
      types[type_lim_start..type_lim_end].each_with_index do |type, rel_type_idx|
        type_idx = rel_type_idx + type_lim_start
        keyparts_limits = get_type_keyparts_limits(type_idx, limits)
        type.generator(keyparts_limits).each do |key, keytype_idx|
          yielder << [key, { type: type_idx, key_part: keytype_idx }]
        end
      end
    end
  end

  private

  def set_key_parts_indexes_to_nil(index, type_idx)
    new_key_parts = {}
    key_parts = index[TYPE_KEY_PARTS_NAME]
    key_parts.keys.each do |key_part|
      new_key_parts[key_part] = nil
    end
    new_key_parts

  end

  def get_type_keyparts_limits(type_idx, limits)
    return nil if !limits

    if type_idx == limits[0][TYPE_IDX_FIELD_NAME]
      lim_start = limits[0][TYPE_KEY_PARTS_NAME]
    else
      lim_start = set_key_parts_indexes_to_nil(limits[0], type_idx)
    end

    if type_idx == limits[1][TYPE_IDX_FIELD_NAME]
      lim_finish = limits[1][TYPE_KEY_PARTS_NAME]
    else
      lim_finish = set_key_parts_indexes_to_nil(limits[1], type_idx)
    end

    [lim_start, lim_finish]
  end
end

class KeyType
  attr_reader :key_formatter, :key_parts

  def initialize(key_formatter)
    @key_formatter = key_formatter
    @key_parts = []
  end

  def <<(keypart)
    key_parts << keypart
  end

  def generator(limits = nil)
    # combine keys from all keyparts
    # recursive cartessian product generator
    key_part_chain_head = build_key_part_chain
    key_part_chain_head.generator(limits).lazy.map { |key_data, idx| [key_formatter.get_key(key_data), idx] }
  end

  private

  class KeyPartElement
    attr_reader :key_part # It is a KeyPart object
    attr_accessor :next_key_part # It is a KeyPartElement object

    def initialize(key_part)
      @key_part = key_part
      @next_key_part = nil
    end

    def generator(limits)
      Enumerator.new do |yielder|
        key_part_limits = get_key_part_limits(key_part, limits)
        key_part.generator(key_part_limits).each do |key_part_elem, key_part_idx|
          # Recursively obtain the key parts
          next_key_part.generator(limits).each do |next_key_part_elem, next_key_part_idx|
            current_idx = { key_part.id => key_part_idx }
            yielder << [key_part_elem.merge(next_key_part_elem), current_idx.merge(next_key_part_idx)]
          end
        end
      end
    end

    def get_key_part_limits(key_part, limits)
      return nil if !key_part #Handle the case of EmptyKeyPartElement class
      return nil if !key_part.id #TODO could this happen??
      return nil if !limits # TODO could this happen??
      [limits[0][key_part.id.to_sym], limits[1][key_part.id.to_sym]]
    end
  end

  # Build linked lists of KeyPart generators
  # Last element is EmptyKeyPartElement
  def build_key_part_chain
    key_part_list = key_parts.map { |key_part| KeyPartElement.new(key_part) }
     # TODO What happens if there are no two elements?
    key_part_list.each_cons(2) { |parent, child| parent.next_key_part = child }
    key_part_list.last.next_key_part = EmptyKeyPartElement.new
    key_part_list.first
  end

  class EmptyKeyPartElement

    attr_reader :key_part

    def initialize
      key_part = nil
    end

    def generator(limits = nil)
      Enumerator.new do |yielder|
        yielder << [{}, {}]
      end
    end
  end
end

class KeyPart
  attr_reader :generators, :id

  GENERATOR_IDX_FIELD_NAME = :generator_index
  private_constant :GENERATOR_IDX_FIELD_NAME

  GENERATOR_CONTENT_IDX_FIELD_NAME = :idx
  private_constant :GENERATOR_CONTENT_IDX_FIELD_NAME

  TYPE_KEY_PARTS_NAME = :key_part
  private_constant :TYPE_KEY_PARTS_NAME

  def initialize(id)
    @generators = []
    @id = id
  end

  def <<(generator)
    generators << generator
  end

  # serialize N generators
  def generator(limits = nil)
    Enumerator.new do |yielder|
      # TODO currently the program crashes in the line below.
      # That's because the assumption that when limits is not null then both indexes
      # of the limits are not nil is not true at this moment. This is because the
      # get_type_keyparts_limits method in the StatsKeyGenerator sets
      # the value of each keypart to nil if the key_type does not correspond
      # with the current one being processed.
      gens_lim_start, gens_lims_end = get_generators_limits(limits) 
      generators[gens_lim_start..gens_lims_end].each_with_index do |gen, rel_gen_idx|
        gen_lims = get_generator_limits(limits)
        gen_idx = rel_gen_idx + gens_lim_start
        gen.generator(gen_lims).each do |elem, elem_idx|
          yielder << [{ id => elem }, { generator_index: gen_idx, idx: elem_idx }]
        end
      end
    end
  end

  private

  def get_generators_limits(limits)
    return [0, generators.size - 1] if !limits
    # TODO Raise exception if some limits component is zero or return defaults???
    lim_start = limits[0][GENERATOR_IDX_FIELD_NAME]
    lim_end = limits[1][GENERATOR_IDX_FIELD_NAME]
    [lim_start, lim_end]
  end

  def get_generator_limits(limits)
    return nil if !limits
    lim_start = limits[0][GENERATOR_CONTENT_IDX_FIELD_NAME]
    lim_end = limits[1][GENERATOR_CONTENT_IDX_FIELD_NAME]
    [lim_start, lim_end]
  end
end

class CustomGenerator
  attr_reader :id
  # TODO decide if the original indexes should be passed via
  # the generator method from the outer classes, and also
  # decide if to send  all the original content object or
  # only the relevant original start and end indexes for
  # each generator, and where to put the responsability
  # of passing this original indexes
  # TODO what if the custom generator does not have
  # original contents? For example, they want to remove
  # applications for the service but do not have users,
  # would we simply do not add a generator for it in
  # that case when building the hierarchy???
  def initialize(id, original_from_idx = 0, original_to_idx = 4)
    @id = id
    @original_from_idx = original_from_idx
    @original_to_idx = original_to_idx
  end

  def generator(limits)
    content_limits = get_generator_content_limits(limits)
    # What to do and how with the content limits will be specific to each generator
    # In this case we will simply iterate them and print its value
    Enumerator.new do |yielder|
      (content_limits[0]..content_limits[1]).each do |i|
        yielder << ["#{id}_#{i}", i]
      end
    end
  end

  def get_generator_content_limits(limits)
    if !limits
      #TODO should get the corresponding elements from service_context
      [@original_from_idx, @original_to_idx]
    else
      return limits
    end
  end
end

class CustomKeyFormatter

  def get_key(metric:, period:, app:)
    "stats/app/#{app}/m/#{metric}/period/#{period}"
  end

end

class CustomKeyFormatter2

  def get_key(metric:, period:, app:)
    "stats2/app/#{app}/m/#{metric}/period/#{period}"
  end

end

period_keypart = KeyPart.new(:period)
period_keypart << CustomGenerator.new('hour')
period_keypart << CustomGenerator.new('day')

app_keypart = KeyPart.new(:app)
app_keypart << CustomGenerator.new('ap')

metric_keypart = KeyPart.new(:metric)
metric_keypart << CustomGenerator.new('met')

# TODO The number of KeyParts a KeyType has is relevant
# because the more number of KeyParts the more
# number of combinations will have. The same
# happens with the number of Generators in a KeyPart.
key_type01 = KeyType.new(CustomKeyFormatter.new)
key_type01 << app_keypart
key_type01 << metric_keypart
key_type01 << period_keypart

key_type02 = KeyType.new(CustomKeyFormatter2.new)
key_type02 << app_keypart
key_type02 << metric_keypart
key_type02 << period_keypart

key_gen = StatsKeyGenerator.new
key_gen << key_type01
key_gen << key_type02

limits = [
{  
	 type: 0,
   key_part: {
     app: { generator_index: 0, :idx => 0 },
     metric: { generator_index: 0, :idx => 2 },
	   period: { generator_index: 1, :idx => 3 },
	 },
},
{  
	 type: 1,
   key_part: {
     app: { generator_index: 0, :idx => 2 },
     metric: { generator_index: 0, :idx => 3},
	   period: { generator_index: 1, :idx => 4 },
	 },
},
]

require 'pp'
#key_gen.generator.take(5).each { |elem| pp elem }

puts "Limits:"
pp limits
puts "-------"

puts "Results:"
key_gen.generator(limits).each { |elem| pp elem }

# Format of a result is an array formed by the key name string
# and the index to locate the key:

# key name string:
# ["stats2/m/met_1/app/ap_4/period/day_4",

# key index:
#   {:type=>1,
#    :key_part=>
#     {:period=>{:generator_index=>1, :idx=>4},
#      :app=>{:generator_index=>0, :idx=>4},
#      :metric=>{:generator_index=>0, :idx=>1}}}]

# It is a hash with two keys, one identifying the type and the other identifying
# the key parts, which is hash where each element is a keypart, which is a hash containing
# into which generator of those has the processing been left and which part of
# that generator has been left.

# TODO it has been observed that inside a given specific key_part, if there
# are multiple generators, the :idx field content must mean the same
# in both of them, and the meaning of increment this index too.
# Otherwise this would not work. This really means that all the generators
# in a key part should be able to use the same field in the service_context
# original job object

# Limits definition:
# Limits are two key indexes.
# If limits is nil it means that all limits should be processed.
# If limits is not nill, necessarily both indexes of the limits must
# be nill. You cannot/should not have a situation where limits is not nil
# and one of the indexes forming the limits is nil