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
  def keyparts 
    Enumerator.new do |yielder|
      generators.each_with_index do |generator, gen_idx|
        generator.generator.each do |elem, elem_idx|
          yielder << [{ id => elem }, { generator_index: gen_idx, idx: elem_idx }]
        end
      end
    end
  end
end
