class KeyType
  attr_reader :key_formatter, :key_parts

  def initialize(key_formatter)
    @key_formatter = key_formatter
    @key_parts = []
  end

  def <<(keypart)
    key_parts << keypart
  end

  def generator(limits)
    key_part_chain_head = build_key_part_chain
    key_part_chain_head.generator(limits).lazy.map do |key_data, idx|
      [key_formatter.get_key(key_data), idx]
    end
  end

  private

  class KeyPartElement
    attr_reader :key_part
    attr_accessor :next_key_part_element

    def initialize(key_part)
      @key_part = key_part
      @next_key_part_element = nil
    end

    def generator(limits)
      Enumerator.new do |yielder|
        # combine keys from all keyparts
        # recursive cartessian product generator
        key_part.keyparts(key_part_limits(limits)).each do |key_part_elem, key_part_idx|
          next_key_part_element.generator(limits).each do |next_key_part_elem, next_key_part_idx|
            current_idx = { key_part.id => key_part_idx }
            yielder << [key_part_elem.merge(next_key_part_elem), current_idx.merge(next_key_part_idx)]
          end
        end
      end
    end

    private

    def key_part_limits(limits)
      return nil if limits.nil?

      lim_start = limits[0][key_part.id] unless limits[0].nil?
      lim_finish = limits[1][key_part.id] unless limits[1].nil?

      [lim_start, lim_finish]
    end
  end

  class EmptyKeyPartElement
    def generator(_limits)
      Enumerator.new do |yielder|
        yielder << [{}, {}]
      end
    end
  end

  # Build linked lists of KeyPart generators
  # Last element is EmptyKeyPartElement
  def build_key_part_chain
    key_part_list = key_parts.map { |key_part| KeyPartElement.new(key_part) }
    key_part_list.each_cons(2) { |parent, child| parent.next_key_part = child }
    key_part_list.last.next_key_part = EmptyKeyPartElement.new
    key_part_list.first
  end
end
