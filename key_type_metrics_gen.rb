require 'ostruct'

module MetricKeyTypeGenerator
  def self.key(service_id, metric_id, datetime)
    "/service/#{service_id}/metric/#{metric_id}/date/#{datetime}"
  end

  def self.get_metric_limits(metric_list, limits)
    list = metric_list || []
    # Array range goes from A to B, (B - A + 1) elements
    return 0, list.size - 1 if limits.nil?
    limits[0..1].map(&:metric).map { |x| x || 0 }
  end

  def self.metric_type_gen(job, limits)
    job.metrics ||= []
    Enumerator.new do |enum|
      metric_idx_from, metric_idx_to = get_metric_limits(job.metrics, limits)
      job.metrics[metric_idx_from..metric_idx_to].each_with_index do |metric_id, metric_range_idx|
        DatetimeGenerator.datetime_generator(job, limits, :service).each do |datetime_key, granularity_idx, ts|
          idx = KeyIndex.new(metric: metric_range_idx, granularity: granularity_idx, ts: ts)
          stats_key = key(job.service_id, metric_id, datetime_key)
          enum << OpenStruct.new(idx: idx, value: stats_key)
        end
      end
    end
  end
end
