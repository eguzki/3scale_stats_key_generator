require_relative('job')
require_relative('key_idx')
require_relative('stats_key_generator')

DELETE_BATCH_SIZE = 50

job = StatsRemovalJob.new(
  applications: [1],
  metrics: Array.new(30) { |idx| (idx + 1) * 10 },
  service_id: 100,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 1, 1, 2)
)

limits = [
  KeyIndex.parse_json('{"key_type":1,"metric":20,"app":0,"user":null,"granularity":0,"ts":0}'),
  KeyIndex.parse_json('{"key_type":1,"metric":22,"app":0,"user":null,"granularity":4,"ts":1483232400}')
]

stats_key_gen = StatsKeyGenerator.key_generator(job, limits)

# method to get keys and abstract idx and value tuple
stats_key_gen.each_slice(DELETE_BATCH_SIZE) do |slice|
  puts '=== delete batch ===='
  puts slice.inspect
end
