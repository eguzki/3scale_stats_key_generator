require_relative('serialize')

class StatsRemovalJob
  include Serialize
  ATTRIBUTES = %i[metrics applications users from to].freeze
  private_constant :ATTRIBUTES
  attr_accessor(*ATTRIBUTES)
end
