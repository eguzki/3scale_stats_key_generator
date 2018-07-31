module PartitionGenerator
  PARTITION_MAX_KEYS = 20
  def self.partitions(key_generator)
    Enumerator.new do |enum|
      key_generator.each_slice(PARTITION_MAX_KEYS) do |slice|
        enum << [slice.first, slice.last]
      end
    end
  end
end
