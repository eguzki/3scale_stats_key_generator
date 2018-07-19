require_relative('serialize')

class StatsRemovalJob
  include Serialize
  ATTRIBUTES = %i[service_id metrics applications users from to].freeze
  private_constant :ATTRIBUTES
  attr_accessor(*ATTRIBUTES)
end
