class PartitionGenerator
  def initialize(key_gen)
    @key_gen = key_gen
  end

  def partitions(size)
    0.step(@key_gen.size, size)
  end
end
