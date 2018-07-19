require_relative('stats_key_generator')
require_relative('key_idx')

DELETE_BATCH_SIZE = 50

job = OpenStruct.new(
  applications: [1],
  metrics: [10],
  service_id: 100,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 4, 5, 1)
)
limits = [
  KeyIndex.parse_json('{"key_type":0,"metric":0,"app":0,"users":null,"granularity":0,"ts":0}'),
  KeyIndex.parse_json('{"key_type":0,"metric":0,"app":0,"users":null,"granularity":4,"ts":1486411200}')
]

stats_key_gen = StatsKeyGenerator.key_generator(job, limits)

# method to get keys and abstract idx and value tuple
stats_key_gen.each_slice(DELETE_BATCH_SIZE) do |slice|
  puts '=== delete batch ===='
  puts slice.inspect
end
