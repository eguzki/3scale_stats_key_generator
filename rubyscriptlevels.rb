#!/usr/bin/env ruby

class StatsKeyGenerator
  attr_reader :types

  def initialize
    @types = []
  end

  def <<(type)
    types << type
  end

	def get_generator
    Enumerator.new do |yielder|
		  types.each_with_index do |type, type_idx|
				type.get_generator(type_idx).each do | key, key_idx |
					yielder << [key, key_idx]
				end
			end
		end
	end
end

class Type
  attr_reader :key_formatter, :id, :root_level

  def initialize(id, key_formatter, root_level)
		@id = id
    @key_formatter = key_formatter
		@root_level = root_level
  end

	def get_generator(type_idx)
    Enumerator.new do |yielder|
      root_level.get_generator(0).each do |key_data, key_level_idx|
			  type_idx = {type: type_idx, idx: key_level_idx}
        yielder << [key_formatter.get_key(key_data), type_idx]
			end
		end
	end
end

class GeneratorLevel
  attr_reader :generators, :id, :param, :next_level

  def initialize(id, param, next_level)
    @generators = []
		@id = id
		@param = param
		@next_level = next_level
  end

  def <<(generator)
    generators << generator
  end

	def get_generator(level)
	  Enumerator.new do |yielder|
			level_generator.each do |elem, elem_idx|
				next_level.get_generator(level+1).each do |next_level_elem, next_level_idx|
				  level_idx = {level_idx: level, idx: elem_idx}
          # TODO The problem is in the merge
			    yielder << [elem.merge(next_level_elem), level_idx.merge(next_level_idx)]
				end
			end
		end
	end

	private

  def level_generator
    Enumerator.new do |yielder|
      generators.each_with_index do |generator, gen_idx|
			  generator.get_generator.each do |elem, elem_idx|
				  obj = {}
					obj[param] = elem
          yielder << [obj, {generator_index: gen_idx, idx: elem_idx}]
				end
      end
		end
	end
end

class EmptyGeneratorLevel < GeneratorLevel
  def initialize

	end

  def get_generator(_level)
    Enumerator.new do |yielder|
		  yielder << [{}, {}]
		end
	end
end

class CustomGenerator
  attr_reader :id
  def initialize(id)
	  @id = id
	end
	def get_generator
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

time_level = GeneratorLevel.new("time_level", :period, EmptyGeneratorLevel.new)
time_hour_generator = CustomGenerator.new("hour")
time_day_generator = CustomGenerator.new("day")

app_level = GeneratorLevel.new("app_level", :app, time_level)
app_generator = CustomGenerator.new("ap")

metric_level = GeneratorLevel.new("metric_level", :metric, app_level)
metric_generator = CustomGenerator.new("met")

time_level << time_hour_generator
time_level << time_day_generator
app_level << app_generator
metric_level << metric_generator

application_metric = Type.new("application_metric", CustomKeyFormatter.new, metric_level)
other_metric = Type.new("other_metric", CustomKeyFormatter2.new, metric_level)

key_gen = StatsKeyGenerator.new
key_gen << application_metric
key_gen << other_metric

require 'pp'
key_gen.get_generator.take(5).each { |elem| pp elem }
