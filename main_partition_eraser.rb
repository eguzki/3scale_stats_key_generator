require 'json'
require_relative('stats_key_factory')
require_relative('key_generator')

job = {
  job: {
    applications: [1],
    metrics: Array.new(30) { |idx| (idx + 1) * 10 },
    service_id: 100,
    from: Time.new(2017, 1, 1, 1).to_i,
    to: Time.new(2017, 1, 1, 2).to_i
  },
  offset: 150,
  length: 50
}

# TODO Validate method of job
## job from and to valid epoch times (in sec)
## job from < to
## application is array
## metrics is array
## service_id exists, maybe service_id exists in db?

stats_key_types = StatsKeysFactory.create(job.job)

stats_key_gen = KeyGenerator.new(stats_key_types)

stats_key_gen.keys.drop().take().each do |slice|
  puts '============== delete batch ====================='
  puts slice.inspect
end
