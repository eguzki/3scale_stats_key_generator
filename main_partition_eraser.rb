require 'json'
require_relative('stats_key_factory')
require_relative('key_generator')

DELETE_BATCH_SIZE = 50

job = {
  applications: [1],
  metrics: Array.new(30) { |idx| (idx + 1) * 10 },
  service_id: 100,
  from: Time.new(2017, 1, 1, 1).to_i,
  to: Time.new(2017, 1, 1, 2).to_i
}

limits = [
  JSON.parse('{"key_type_idx":0,"key_idx":{"period":{"generator_index":0,"idx":1483228800},"app":{"generator_index":0,"idx":0},"metric":{"generator_index":0,"idx":0}}}',
             symbolize_names: true),
  JSON.parse('{"key_type_idx":0,"key_idx":{"period":{"generator_index":0,"idx":1483232400},"app":{"generator_index":0,"idx":0},"metric":{"generator_index":0,"idx":19}}}',
             symbolize_names: true)
]

limits2 = [
  JSON.parse('{"key_type_idx":0,"key_idx":{"period":{"generator_index":1,"idx":1483228800},"app":{"generator_index":0,"idx":0},"metric":{"generator_index":0,"idx":20}}}',
             symbolize_names: true),
  JSON.parse('{"key_type_idx":1,"key_idx":{"period":{"generator_index":1,"idx":1483228800},"metric":{"generator_index":0,"idx":9}}}',
             symbolize_names: true)
]

limits3 = [
  JSON.parse('{"key_type_idx":1,"key_idx":{"period":{"generator_index":1,"idx":1483228800},"metric":{"generator_index":0,"idx":10}}}',
             symbolize_names: true),
  JSON.parse('{"key_type_idx":1,"key_idx":{"period":{"generator_index":1,"idx":1483228800},"metric":{"generator_index":0,"idx":29}}}',
             symbolize_names: true)
]

# TODO Validate method of job and limits
## job from and to valid epoch times (in sec)
## job from < to
## application is array
## metrics is array
## service_id exists, maybe service_id exists in db?
## limits -> json schema match?

stats_key_types = StatsKeysFactory.create

stats_key_gen = KeyGenerator.new(stats_key_types, job: job, limits: limits)

stats_key_gen.keys.each_slice(DELETE_BATCH_SIZE) do |slice|
  puts '============== delete batch ====================='
  puts slice.inspect
end
