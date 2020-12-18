# frozen_string_literal: true

require_relative 'slowssz/version'

module Slowssz
  class WrongType < StandardError; end
  class IncorrectSize < StandardError; end
  class ListTooBig < StandardError; end

  class Uint8
    attr_reader :value

    private

    def initialize(value = 0)
      @value = value % 0xff
    end
  end

  class Uint16
    attr_reader :value

    private

    def initialize(value = 0)
      @value = value % 0xffff
    end
  end

  class Uint32
    attr_reader :value

    private

    def initialize(value = 0)
      @value = value % 0xffffffff
    end
  end

  class Uint64
    attr_reader :value

    private

    def initialize(value = 0)
      @value = value % 0xffffffffffffffff
    end
  end

  class Boolean
    attr_reader :value

    private

    def initialize(value = false)
      @value = !!value
    end
  end

  class BitVector
    attr_reader :value, :size

    def val(value)
      raise IncorrectSize unless value.size == @size

      @value = value

      self
    end

    private

    def initialize(value)
      @size = value.size
      val(value)
    end
  end

  class BitList
    attr_reader :value, :capacity

    def <<(bit)
      raise ListTooBig if @value.size > @capacity

      @value << bit
    end

    def size
      @value.size
    end

    private

    def initialize(value, capacity)
      @capacity = capacity
      raise ListTooBig if value.size > @capacity

      @value = value
    end
  end

  class Vector
    attr_reader :value, :type, :size

    def val(value)
      raise IncorrectSize unless value.size == @size
      raise WrongType unless value.all? { |v| v.is_a?(@type) }

      @value = value

      self
    end

    private

    def initialize(type, value)
      @type = type
      @size = value.size
      val(value)
    end
  end

  class List
    attr_reader :value, :type, :capacity

    def val(value)
      raise ListTooBig if value.size >= capacity

      new_value = []
      value.each do |v|
        raise WrongType unless v.is_a?(@type)

        new_value << v
      end

      @value = new_value

      self
    end

    def <<(ele)
      raise ListTooBig if size >= capacity
      raise WrongType unless ele.is_a?(type)

      @value << ele
    end

    def size
      @value.size
    end

    private

    def initialize(type, capacity)
      @type = type
      @capacity = capacity
      @value = []
    end
  end

  class Marshal
    class << self
      def dump(obj)
        if obj.is_a?(Boolean)
          dump_bool(obj)
        elsif obj.is_a?(BitVector)
          dump_bit_vector(obj)
        elsif obj.is_a?(BitList)
          dump_bit_list(obj)
        elsif obj.is_a?(Uint8)
          dump_uint8(obj)
        elsif obj.is_a?(Uint16)
          dump_uint16(obj)
        elsif obj.is_a?(Uint32)
          dump_uint32(obj)
        elsif obj.is_a?(Uint64)
          dump_uint64(obj)
        elsif obj.is_a?(List)
          dump_list(obj)
        else
          ''
        end
      end

      private

      def dump_bool(bool)
        [bool.value ? '1' : '0'].pack('b')
      end

      def dump_bit_vector(bit_vector)
        [bit_vector.value.inject('') { |str, bool| str + (bool ? '1' : '0') }].pack('b*')
      end

      def dump_bit_list(bit_list)
        [bit_list.value.inject('') { |str, bool| str + (bool ? '1' : '0') }.concat('1')].pack('b*')
      end

      def dump_uint8(uint8)
        [uint8.value].pack('C')
      end

      def dump_uint16(uint16)
        [uint16.value].pack('v')
      end

      def dump_uint32(uint32)
        [uint32.value].pack('V')
      end

      def dump_uint64(uint64)
        [uint64.value].pack('Q<')
      end

      def dump_list(list)
        list.value.inject('') { |str, v| str + dump(v) }
      end
    end
  end
end
