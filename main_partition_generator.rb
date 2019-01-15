require 'json'
require_relative('stats_key_factory')
require_relative('key_generator')
require_relative('partition_generator')

PARTITION_BATCH_SIZE = 50

job = {
  applications: [1],
  metrics: Array.new(30) { |idx| (idx + 1) * 10 },
  service_id: 100,
  from: Time.new(2017, 1, 1, 1).to_i,
  to: Time.new(2017, 1, 1, 2).to_i
}

stats_key_types = StatsKeysFactory.create(job)

stats_key_gen = KeyGenerator.new(stats_key_types)

partition_generator = PartitionGenerator.new(stats_key_gen)

partition_generator.partitions(PARTITION_BATCH_SIZE).each do |idx|
  # generate resque job
  puts({ job: job, offset: idx, length: PARTITION_BATCH_SIZE }.to_json)
end
