require 'json'

DELETE_BATCH_SIZE = 50

job = {
  applications: [1],
  metrics: Array.new(30) { |idx| (idx + 1) * 10 },
  service_id: 100,
  from: Time.new(2017, 1, 1, 1),
  to: Time.new(2017, 1, 1, 2)
}

limits = [
  {
    key_type_idx: 0,
    key_idx: {
      period: { generator_index: 0, idx: 0 },
      app: { generator_index: 0, idx: 0 },
      metric: { generator_index: 0, idx: 0 }
    }
  },
  {
    key_type_idx: 0,
    key_idx: {
      period: { generator_index: 0, idx: 0 },
      app: { generator_index: 0, idx: 0 },
      metric: { generator_index: 0, idx: 4 }
    }
  }
]

stats_key_types = StatsKeysFactory.create

stats_key_gen = KeyGenerator.new(stats_key_types, job, limits)

stats_key_gen.keys.each_slice(DELETE_BATCH_SIZE) do |slice|
  puts '=== delete batch ===='
  puts slice.inspect
end
