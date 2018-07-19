require 'ostruct'

module UserKeyTypeGenerator
  def self.key(service_id, user_id, metric_id, datetime)
    "/service/#{service_id}/user/#{user_id}/metric/#{metric_id}/date/#{datetime}"
  end

  def self.get_user_limits(user_list, limits)
    list = user_list || []
    # Array range goes from A to B, (B - A + 1) elements
    return 0, list.size - 1 if limits.nil?
    limits[0..1].map(&:user).map { |x| x || 0 }
  end

  def self.get_metric_limits(metric_list, limits)
    list = metric_list || []
    # Array range goes from A to B, (B - A + 1) elements
    return 0, list.size - 1 if limits.nil?
    limits[0..1].map(&:metric).map { |x| x || 0 }
  end

  def self.user_type_gen(job, limits)
    Enumerator.new do |enum|
      user_idx_from, user_idx_to = get_user_limits(job.users, limits)
      metric_idx_from, metric_idx_to = get_metric_limits(job.metrics, limits)
      job.users[user_idx_from..user_idx_to].each_with_index do |user_id, user_range_idx|
        job.metrics[metric_idx_from..metric_idx_to].each_with_index do |metric_id, metric_range_idx|
          DatetimeGenerator.datetime_generator(job, limits, :app).each do |datetime_key, granularity_idx, ts|
            idx = KeyIndex.new(user: user_range_idx, metric: metric_range_idx, granularity: granularity_idx, ts: ts)
            stats_key = key(job.service_id, user_id, metric_id, datetime_key)
            enum << OpenStruct.new(idx: idx, value: stats_key)
          end
        end
      end
    end
  end
end
