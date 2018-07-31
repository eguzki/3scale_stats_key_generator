class MetricGenerator < Generator
end




module KeyTypeGenerator
  KEY_TYPE_GENERATORS = [
    MetricKeyTypeGenerator.method(:metric_type_gen),
    AppsKeyTypeGenerator.method(:apps_type_gen),
    UserKeyTypeGenerator.method(:user_type_gen)
  ].freeze

  def self.get_key_type_limits(limits)
    # Array range goes from A to B, (B - A + 1) elements
    return 0, KEY_TYPE_GENERATORS.size - 1 if limits.nil?
    [limits[0].key_type, limits[1].key_type]
  end

  def self.key_type_generator(job, limits = nil)
    idx_from, idx_to = get_key_type_limits limits
    Enumerator.new do |enum|
      KEY_TYPE_GENERATORS[idx_from..idx_to].each_with_index do |gen, idx|
        gen.call(job, limits).each do |elem|
          elem.idx.key_type = idx
          enum << elem
        end
      end
    end
  end
end
