class KeyPart
  attr_reader :generators, :id

  GENERATOR_INDEX = :generator_index
  private_constant :GENERATOR_INDEX

  INDEX = :idx
  private_constant :INDEX

  def initialize(id)
    @generators = []
    @id = id
  end

  def <<(generator)
    generators << generator
  end

  # serialize N generators
  def keypart_elems(job:, limits:)
    lim_start, lim_end = generators_limits(limits)
    Enumerator.new do |yielder|
      generators[lim_start..lim_end].to_enum.with_index(lim_start) do |generator, gen_idx|
        generator.items(job: job, limits: generator_limits(limits, gen_idx)).each do |items, item_idx|
          yielder << [{ id => items }, { GENERATOR_INDEX => gen_idx, INDEX => item_idx }]
        end
      end
    end
  end

  private

  def generator_limits(limits, gen_idx)
    return nil if limits.nil?

    lim_start = limits[0][INDEX] if !limits[0].nil? && gen_idx == limits[0][GENERATOR_INDEX]

    lim_finish = limits[1][INDEX] if !limits[1].nil? && gen_idx == limits[1][GENERATOR_INDEX]

    [lim_start, lim_finish]
  end

  def generators_limits(limits)
    return [0, generators.size - 1] if limits.nil?

    lim_start = if limits[0].nil?
                  0
                else
                  limits[0][GENERATOR_INDEX]
                end

    lim_end = if limits[1].nil?
                generators.size - 1
              else
                limits[1][GENERATOR_INDEX]
              end

    [lim_start, lim_end]
  end
end
