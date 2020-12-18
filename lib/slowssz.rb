# frozen_string_literal: true

require_relative 'slowssz/version'

module Slowssz
  class ListTooBig < StandardError; end

  class BitVector
    attr_reader :value

    def <<(bit)
      @value << bit
    end

    def size
      @value.size
    end

    private

    def initialize(value)
      @value = value
    end
  end

  class BitList
    attr_reader :value, :capacity

    def <<(bit)
      raise ListTooBig if @value.size > @capacity

      @value << bit
    end

    private

    def initialize(value, capacity)
      @capacity = capacity
      raise ListTooBig if value.size > @capacity

      @value = value
    end
  end

  class Marshal
    class << self
      def dump(obj)
        if obj.is_a?(BitVector)
          dump_bit_vector(obj)
        elsif obj.is_a?(BitList)
          dump_bit_list(obj)
        elsif obj.is_a?(TrueClass) || obj.is_a?(FalseClass)
          dump_bool(obj)
        end
      end

      private

      def dump_bool(bool)
        [bool ? '1' : '0'].pack('b')
      end

      def dump_bit_vector(bit_vector)
        [bit_vector.value.inject('') { |str, bool| str + (bool ? '1' : '0') }].pack('b*')
      end

      def dump_bit_list(bit_list)
        [bit_list.value.inject('') { |str, bool| str + (bool ? '1' : '0') }.concat('1')].pack('b*')
      end
    end
  end
end
