#!/usr/bin/env ruby

class StatsKeyGenerator
  attr_reader :types

  def initialize
    @types = []
  end

  def <<(type)
    types << type
  end

  def generator
    Enumerator.new do |yielder|
      types.each_with_index do |type, type_idx|
        type.generator.each do |key, keytype_idx|
          yielder << [key, { type: type_idx, key_part: keytype_idx }]
        end
      end
    end
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

  def generator
    # combine keys from all keyparts
    # recursive cartessian product generator
    key_part_chain_head = build_key_part_chain
    key_part_chain_head.generator.lazy.map { |key_data, idx| [key_formatter.get_key(key_data), idx] }
  end

  private

  class KeyPartElement
    attr_reader :key_part
    attr_accessor :next_key_part

    def initialize(key_part)
      @key_part = key_part
      @next_key_part = nil
    end

    def generator
      Enumerator.new do |yielder|
        key_part.generator.each do |key_part_elem, key_part_idx|
          next_key_part.generator.each do |next_key_part_elem, next_key_part_idx|
            current_idx = { key_part.id => key_part_idx }
            yielder << [key_part_elem.merge(next_key_part_elem), current_idx.merge(next_key_part_idx)]
          end
        end
      end
    end
  end

  class EmptyKeyPartElement
    def generator
      Enumerator.new do |yielder|
        yielder << [{}, {}]
      end
    end
  end

  # Build linked lists of KeyPart generators
  # Last element is EmptyKeyPartElement
  def build_key_part_chain
    key_part_list = key_parts.map { |key_part| KeyPartElement.new(key_part) }
    key_part_list.each_cons(2) { |parent, child| parent.next_key_part = child }
    key_part_list.last.next_key_part = EmptyKeyPartElement.new
    key_part_list.first
  end
end

class KeyPart
  attr_reader :generators, :id

  def initialize(id)
    @generators = []
    @id = id
  end

  def <<(generator)
    generators << generator
  end

  # serialize N generators
  def generator
    Enumerator.new do |yielder|
      generators.each_with_index do |generator, gen_idx|
        generator.generator.each do |elem, elem_idx|
          yielder << [{ id => elem }, { generator_index: gen_idx, idx: elem_idx }]
        end
      end
    end
  end
end

class CustomGenerator
  attr_reader :id
  def initialize(id)
    @id = id
  end

  def generator
    Enumerator.new do |yielder|
      5.times.each do |i|
        yielder << ["#{id}_#{i}", i]
      end
    end
  end
end

class CustomKeyFormatter

  def get_key(metric:, period:, app:)
   "stats/m/#{metric}/app/#{app}/period/#{period}"
  end

end

class CustomKeyFormatter2

  def get_key(metric:, period:, app:)
   "stats2/m/#{metric}/app/#{app}/period/#{period}"
  end

end

period_keypart = KeyPart.new(:period)
period_keypart << CustomGenerator.new('hour')
period_keypart << CustomGenerator.new('day')

app_keypart = KeyPart.new(:app)
app_keypart << CustomGenerator.new('ap')

metric_keypart = KeyPart.new(:metric)
metric_keypart << CustomGenerator.new('met')

key_type01 = KeyType.new(CustomKeyFormatter.new)
key_type01 << period_keypart
key_type01 << app_keypart
key_type01 << metric_keypart

key_type02 = KeyType.new(CustomKeyFormatter2.new)
key_type02 << period_keypart
key_type02 << app_keypart
key_type02 << metric_keypart

key_gen = StatsKeyGenerator.new
key_gen << key_type01
key_gen << key_type02

require 'pp'
key_gen.generator.take(5).each { |elem| pp elem }
