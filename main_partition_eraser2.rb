require_relative('stats_key_generator')
require_relative('key_idx')

DELETE_BATCH_SIZE = 50

job = OpenStruct.new(
  users: [1, 2],
  applications: [10, 20],
  metrics: [100, 200],
  service_id: 1000,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 1, 1, 5)
)
limits = [
  KeyIndex.parse_json('{"key_type":0,"metric":0,"app":null,"user":null,"granularity":0,"ts":0}'),
  KeyIndex.parse_json('{"key_type":2,"metric":1,"app":null,"user":1,"granularity":5,"ts":1483225200}')
]

stats_key_gen = StatsKeyGenerator.key_generator(job, limits)

# method to get keys and abstract idx and value tuple
stats_key_gen.each_slice(DELETE_BATCH_SIZE) do |slice|
  puts '=== delete batch ===='
  puts slice.inspect
end
