require_relative('key_type_gen')

module StatsKeyGenerator
  def self.index_generator(job)
    KeyTypeGenerator.key_type_generator(job).lazy.map(&:idx)
  end

  def self.key_generator(job, limits)
    KeyTypeGenerator.key_type_generator(job, limits).lazy.map(&:value)
  end
end
