class AppKeyFormatter
  def get_key(metric:, period:, app:)
    "stats/m/#{metric}/app/#{app}/period/#{period}"
  end
end

class MetricKeyFormatter
  def get_key(metric:, period:)
    "stats2/m/#{metric}/period/#{period}"
  end
end
