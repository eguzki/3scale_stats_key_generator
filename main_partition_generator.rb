require 'json'

PARTITION_BATCH_SIZE = 50

job = {
  applications: [1],
  metrics: Array.new(30) { |idx| (idx + 1) * 10 },
  service_id: 100,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 1, 1, 2)
}

stats_key_types = StatsKeysFactory.create

stats_key_gen = KeyGenerator.new(stats_key_types, job)

partition_generator = PartitionGenerator.new(stats_key_gen)

partition_generator.partitions(PARTITION_BATCH_SIZE).each do |from_limit, to_limit|
  # generate resque job
  puts '=== Partition ==='
  puts "from: #{from_limit.to_json}"
  puts "to: #{to_limit.to_json}"
end
