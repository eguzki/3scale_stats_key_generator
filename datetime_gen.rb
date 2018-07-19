require 'time'

module DatetimeGenerator
  class Period
    attr_accessor :idx
    def initialize(generator_idx)
      @idx = generator_idx
    end

    def get_limits(job, limits)
      return job.from, job.to if limits.nil?
      from_generator_idx, to_generator_idx = limits[0..1].map(&:granularity)
      from_limit, to_limit = limits[0..1].map(&:ts).map { |g| Time.at(g) }
      from = job.from
      to = job.to
      # Only use limit from partition limits when partition index generator is current generator
      from = from_limit if from_generator_idx == idx
      to = to_limit if to_generator_idx == idx
      [from, to]
    end

    def datetime_generator(job, limits)
      Enumerator.new do |enum|
        from, to = get_limits(job, limits).map { |ts| period_start(ts) }
        while from <= to
          enum << [period_key(from), from.to_i]
          from = period_step(from)
        end
      end
    end

    def period_start(_ts)
      raise Exception, 'base period has no step implementation'
    end

    def period_step(_ts)
      raise Exception, 'base period has no step implementation'
    end

    def period_key(_ts)
      raise Exception, 'base period has no key implementation'
    end
  end

  class EternityPeriod < Period
    def datetime_generator(_job, _limits)
      Enumerator.new do |enum|
        enum << ['eternity', 0]
      end
    end
  end

  class YearPeriod < Period
    def period_step(ts)
      Time.new(ts.year + 1, ts.month, ts.day, ts.hour)
    end

    def period_key(ts)
      ts.strftime('year:%Y')
    end

    def period_start(ts)
      Time.new(ts.year)
    end
  end

  class MonthPeriod < Period
    def period_step(ts)
      new_ts = ts.to_date >> 1
      Time.new(new_ts.year, new_ts.month)
    end

    def period_key(ts)
      ts.strftime('month:%Y%m')
    end

    def period_start(ts)
      Time.new(ts.year, ts.month)
    end
  end

  class WeekPeriod < Period
    def period_step(ts)
      new_ts = ts.to_date + 7
      Time.new(new_ts.year, new_ts.month, new_ts.day)
    end

    def period_key(ts)
      ts.strftime('week:%Y%m%d')
    end

    def period_start(ts)
      # wday 0 is sunday
      # numbers of days to substract:
      # 0 -> 6, 1 -> 0, 2 -> 1, ....., 6 -> 5
      new_ts = ts.to_date - ((ts.to_date.wday - 1) % 7)
      Time.new(new_ts.year, new_ts.month, new_ts.day)
    end
  end

  class DayPeriod < Period
    def period_step(ts)
      new_ts = ts.to_date + 1
      Time.new(new_ts.year, new_ts.month, new_ts.day)
    end

    def period_key(ts)
      ts.strftime('day:%Y%m%d')
    end

    def period_start(ts)
      Time.new(ts.year, ts.month, ts.day)
    end
  end

  class HourPeriod < Period
    def period_step(ts)
      new_ts = ts + 3600
      Time.new(new_ts.year, new_ts.month, new_ts.day, new_ts.hour)
    end

    def period_key(ts)
      ts.strftime('hour:%Y%m%d%H')
    end

    def period_start(ts)
      Time.new(ts.year, ts.month, ts.day, ts.hour)
    end
  end

  def self.granularity_to_period(granularity_arr)
    granularity_arr.each_with_index.map do |name, idx|
      DatetimeGenerator.const_get("#{name.to_s.capitalize}Period").new(idx)
    end
  end

  SERVICE_GRANULARITIES = [:eternity, :month, :week, :day, :hour].freeze
  # For applications and users
  EXPANDED_GRANULARITIES = (SERVICE_GRANULARITIES + [:year]).freeze

  SERVICE_PERIODS = granularity_to_period(SERVICE_GRANULARITIES)
  EXPANDED_PERIODS = granularity_to_period(EXPANDED_GRANULARITIES)

  def self.granularities(metric_type)
    metric_type == :service ? SERVICE_PERIODS : EXPANDED_PERIODS
  end

  def self.get_granularity_limits(granularity_list, limits)
    # Array range goes from A to B, (B - A + 1) elements
    return 0, granularity_list.size - 1 if limits.nil?
    limits[0..1].map(&:granularity)
  end

  def self.datetime_generator(job, limits, metric_type)
    Enumerator.new do |enum|
      granularity_idx_from, granularity_idx_to = get_granularity_limits(granularities(metric_type), limits)
      granularities(metric_type)[granularity_idx_from..granularity_idx_to].each_with_index do |granularity, granularity_idx|
        granularity.datetime_generator(job, limits).each do |datetime_key, ts|
          enum << [datetime_key, granularity_idx, ts]
        end
      end
    end
  end
end
