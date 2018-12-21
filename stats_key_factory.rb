class AppKeyTypeFactory
  def self.create
    period_keypart = KeyPart.new(:period)
    period_keypart << HourGenerator.new
    period_keypart << DayGenerator.new

    app_keypart = KeyPart.new(:app)
    app_keypart << AppGenerator.new

    metric_keypart = KeyPart.new(:metric)
    metric_keypart << MetricGenerator.new

    KeyType.new(AppKeyFormatter.new).tap do |key_type|
      key_type << period_keypart
      key_type << app_keypart
      key_type << metric_keypart
    end
  end
end

class MetricKeyTypeFactory
  def self.create
    period_keypart = KeyPart.new(:period)
    period_keypart << HourGenerator.new
    period_keypart << DayGenerator.new

    metric_keypart = KeyPart.new(:metric)
    metric_keypart << MetricGenerator.new

    KeyType.new(MetricKeyFormatter.new).tap do |key_type|
      key_type << period_keypart
      key_type << metric_keypart
    end
  end
end

class StatsKeysFactory
  def self.create
    [].tap do |keys|
      keys << AppKeyTypeFactory.create
      keys << MetricKeyTypeFactory.create
    end
  end
end
