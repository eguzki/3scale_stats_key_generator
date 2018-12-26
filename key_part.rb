class KeyPart
  attr_reader :generators, :id

  def initialize(id)
    @generators = []
    @id = id
  end

  def <<(generator)
    generators << generator
  end

  # serialize N generators
  def keypart_elems
    Enumerator.new do |yielder|
      generators.each do |generator|
        generator.items.each do |items|
          yielder << { id => items }
        end
      end
    end
  end
end
