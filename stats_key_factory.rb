class AppKeyTypeFactory
  def self.create(job)
    period_keypart = KeyPart.new(:period)
    period_keypart << HourGenerator.new(job)
    period_keypart << DayGenerator.new(job)

    app_keypart = KeyPart.new(:app)
    app_keypart << AppGenerator.new(job)

    metric_keypart = KeyPart.new(:metric)
    metric_keypart << MetricGenerator.new(job)

    KeyType.new(AppKeyFormatter.new).tap do |key_type|
      key_type << period_keypart
      key_type << app_keypart
      key_type << metric_keypart
    end
  end
end

class MetricKeyTypeFactory
  def self.create(job)
    period_keypart = KeyPart.new(:period)
    period_keypart << HourGenerator.new(job)
    period_keypart << DayGenerator.new(job)

    metric_keypart = KeyPart.new(:metric)
    metric_keypart << MetricGenerator.new(job)

    KeyType.new(MetricKeyFormatter.new).tap do |key_type|
      key_type << period_keypart
      key_type << metric_keypart
    end
  end
end

class StatsKeysFactory
  def self.create(job)
    [].tap do |keys|
      keys << AppKeyTypeFactory.create(job)
      keys << MetricKeyTypeFactory.create(job)
    end
  end
end
