require 'ostruct'
require_relative('stats_key_partition_generator')
require_relative('stats_key_generator')


job = OpenStruct.new(
  applications: [1],
  metrics: [10],
  service_id: 100,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 4, 5, 1)
)

stats_key_gen = StatsKeyGenerator.index_generator(job)

PartitionGenerator.partitions(stats_key_gen).each do |from, to|
  # generate resque job
  puts "from: #{from.to_json}"
  puts "to: #{to.to_json}"
end
