require_relative('metric_generator')

class StatsKeyGenerator
  class Node
    attr_reader :generator, :siblings

    def initialize(generator)
      @generator = generator
      @siblings = []
    end

    def <<(node)
      @sibling << node
    end

    def generate(job, data)
      Enumerator.new do |enum|
        generator.call(job, data).each do |elem, idx|
          siblings.each do |gen, gen_idx|
          end
        end
      end
    end
  end

  @instance = nil

  def self.instance
    @instance ||= factory
  end

  def self.gen_idx(job)
    root.generate(job, Openstruct.new).lazy.map(&:idx)
  end

  private

  def self.factory
    #
    # service_type
    #
    service_type = Node.new(MetricGenerator.new)
    service_type << Node.new(MonthPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)
    service_type << Node.new(DayPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)

    #
    # app type
    #
    app_type = Node.new(MetricGenerator.new)
    app_type_child = Node.new(AppGenerator.new)
    app_type << app_type_child
    app_type_child << Node.new(MonthPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)
    app_type_child << Node.new(YearPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)
    app_type_child << Node.new(DayPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)

    #
    # user type
    #
    user_type = Node.new(MetricGenerator.new)
    user_type_child = Node.new(UserGenerator.new)
    user_type << user_type_child
    user_type_child << Node.new(MonthPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)
    user_type_child << Node.new(YearPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)
    user_type_child << Node.new(DayPeriodGenerator.new) << Node.new(SingleStatKeyGenerator.new)

    root_node = Node.new(VoidGenerator.new)
    root_node << service_type
    root_node << app_type
    root_node << user_type
    new root_node
  end

  def initialize(root_node)
    @root = root_node
  end

  attr_reader :root
end
