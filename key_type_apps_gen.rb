require_relative('datetime_gen')
require_relative('key_idx')
require 'ostruct'

module AppsKeyTypeGenerator
  def self.key(service_id, app_id, metric_id, datetime)
    "/service/#{service_id}/app/#{app_id}/metric/#{metric_id}/date/#{datetime}"
  end

  def self.get_app_limits(app_list, limits)
    list = app_list || []
    # Array range goes from A to B, (B - A + 1) elements
    return 0, list.size - 1 if limits.nil?
    limits[0..1].map(&:app).map { |x| x || 0 }
  end

  def self.get_metric_limits(metric_list, limits)
    list = metric_list || []
    # Array range goes from A to B, (B - A + 1) elements
    return 0, list.size - 1 if limits.nil?
    limits[0..1].map(&:metric).map { |x| x || 0 }
  end

  def self.apps_type_gen(job, limits)
    Enumerator.new do |enum|
      app_idx_from, app_idx_to = get_app_limits(job.applications, limits)
      metric_idx_from, metric_idx_to = get_metric_limits(job.metrics, limits)
      job.applications[app_idx_from..app_idx_to].each_with_index do |app_id, app_range_idx|
        job.metrics[metric_idx_from..metric_idx_to].each_with_index do |metric_id, metric_range_idx|
          DatetimeGenerator.datetime_generator(job, limits, :app).each do |datetime_key, granularity_idx, ts|
            idx = KeyIndex.new(app: app_range_idx, metric: metric_range_idx, granularity: granularity_idx, ts: ts)
            stats_key = key(job.service_id, app_id, metric_id, datetime_key)
            enum << OpenStruct.new(idx: idx, value: stats_key)
          end
        end
      end
    end
  end
end
