class DayGenerator
end

class AppGenerator
end

class MetricGenerator
end

class HourGenerator
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

class HourGenerator
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
