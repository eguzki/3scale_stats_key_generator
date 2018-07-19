require 'ostruct'
require_relative('stats_key_partition_generator')
require_relative('stats_key_generator')

job = OpenStruct.new(
  users: [1, 2],
  applications: [10, 20],
  metrics: [100, 200],
  service_id: 1000,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 1, 1, 5)
)

stats_key_gen = StatsKeyGenerator.index_generator(job)

PartitionGenerator.partitions(stats_key_gen).each do |from, to|
  # generate resque job
  puts "from: #{from.to_json}"
  puts "to: #{to.to_json}"
end
