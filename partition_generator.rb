class PartitionGenerator
  def initialize(key_gen)
    @key_gen = key_gen
  end

  def partitions(size)
    @key_gen.indexes.each_slice(size).lazy.map { |slice| [slice.first, slice.last] }
  end
end
