class AppGenerator
  def items(job:, limits:)
    apps = job[:applications] || []
    start, finish = app_limits(limits, apps)
    apps[start..finish].to_enum.with_index(start)
  end

  private

  def app_limits(limits, apps)
    return [0, apps.size - 1] if limits.nil?

    [limits[0] || 0, limits[1] || (apps.size - 1)]
  end
end

class MetricGenerator
  def items(job:, limits:)
    metrics = job[:metrics] || []
    start, finish = metrics_limits(limits, metrics)
    metrics[start..finish].to_enum.with_index(start)
  end

  private

  def metrics_limits(limits, metrics)
    return [0, metrics.size - 1] if limits.nil?

    [limits[0] || 0, limits[1] || (metrics.size - 1)]
  end
end

class DayGenerator
  def items(job:, limits:)
    from, to = period_limits(job: job, limits: limits).map { |t| Time.at(t) }
    Enumerator.new do |yielder|
      curr_time = from
      while curr_time <= to
        yielder << [curr_time.strftime('%Y%m%d'), curr_time.to_i]
        curr_time += 3600 * 24
      end
    end
  end

  def period_limits(job:, limits:)
    return [job[:from], job[:to]] if limits.nil?

    [limits[0] || job[:from], limits[1] || job[:to]]
  end
end

class HourGenerator
  def items(job:, limits:)
    from, to = period_limits(job: job, limits: limits).map { |t| Time.at(t) }
    Enumerator.new do |yielder|
      curr_time = from
      while curr_time <= to
        yielder << [curr_time.strftime('%Y%m%d%H'), curr_time.to_i]
        curr_time += 3600
      end
    end
  end

  def period_limits(job:, limits:)
    return [job[:from], job[:to]] if limits.nil?

    [limits[0] || job[:from], limits[1] || job[:to]]
  end
end
