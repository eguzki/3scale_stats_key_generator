module Generator
  attr_reader :job
  def initialize(job)
    @job = job
  end
end

class AppGenerator
  include Generator
  
  def items
    job[:applications].each
  end
end

class MetricGenerator
  include Generator

  def items
    job[:metrics].each
  end
end

class DayGenerator
  include Generator

  def items
    from, to = [job[:from], job[:to]].map { |t| Time.at(t) }
    Enumerator.new do |yielder|
      curr_time = from
      while curr_time <= to
        yielder << curr_time.strftime('%Y%m%d')
        curr_time += 3600 * 24
      end
    end
  end
end

class HourGenerator
  include Generator

  def items
    from, to = [job[:from], job[:to]].map { |t| Time.at(t) }
    Enumerator.new do |yielder|
      curr_time = from
      while curr_time <= to
        yielder << curr_time.strftime('%Y%m%d%H')
        curr_time += 3600
      end
    end
  end
end
