# frozen_string_literal: true

require_relative 'slowssz/version'

module Slowssz
  class WrongType < StandardError; end
  class IncorrectSize < StandardError; end
  class ListTooBig < StandardError; end
  class InsufficientArguments < StandardError; end

  BYTES_PER_LENGTH_OFFSET = 4

  class Uint8
    attr_reader :value

    def type
      Uint8
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(value = 0)
      @value = value % 0x100
    end
  end

  class Uint16
    attr_reader :value

    def type
      Uint16
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(value = 0)
      @value = value % 0x10000
    end
  end

  class Uint32
    attr_reader :value

    def type
      Uint32
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(value = 0)
      @value = value % 0x100000000
    end
  end

  class Uint64
    attr_reader :value

    def type
      Uint64
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(value = 0)
      @value = value % 0x10000000000000000
    end
  end

  class Boolean
    attr_reader :value

    def type
      Boolean
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(value = false)
      @value = !!value
    end
  end

  class BitVectorType
    attr_reader :size

    def self.of(size:)
      new(size)
    end

    def new(value)
      BitVector.new(self, value)
    end

    def variable_size?
      false
    end

    private

    def initialize(size)
      @size = size
    end
  end

  class BitVector
    attr_reader :value, :type

    def size
      @type.size
    end

    def variable_size?
      @type.variable_size?
    end

    private

    def initialize(type, value)
      @type = type

      raise IncorrectSize unless value.size == @type.size

      @value = value
    end
  end

  class BitListType
    attr_reader :limit

    def self.of(limit:)
      new(limit)
    end

    def new(value)
      BitList.new(self, value)
    end

    def variable_size?
      true
    end

    private

    def initialize(limit)
      @limit = limit
    end
  end

  class BitList
    attr_reader :value, :type

    def <<(bit)
      raise ListTooBig if @value.size > @capacity

      @value << bit
    end

    def size
      @value.size
    end

    def limit
      @type.limit
    end

    def variable_size?
      @type.variable_size?
    end

    private

    def initialize(type, value)
      @type = type

      raise ListTooBig if value.size > @type.limit

      @value = value
    end
  end

  class VectorType
    attr_reader :type, :size

    def self.of(type:, size:)
      new(type, size)
    end

    def new(value)
      Vector.new(self, value)
    end

    def ==(other)
      type == other.type && size == other.size
    end

    def variable_size?
      @type.type.variable_size?
    end

    private

    def initialize(type, size)
      @type = type
      @size = size
    end
  end

  class Vector
    attr_reader :value, :type

    def value_type
      @type.type
    end

    def size
      @type.size
    end

    def variable_size?
      @type.variable_size?
    end

    private

    def initialize(type, value)
      @type = type

      raise IncorrectSize unless value.size == @type.size
      raise WrongType, "#{ele.type} vs #{@type.type}" unless value.all? { |ele| ele.type == @type.type }

      @value = value
    end
  end

  class ListType
    attr_reader :type, :limit

    def self.of(type:, limit:)
      new(type, limit)
    end

    def new(value)
      List.new(self, value)
    end

    def ==(other)
      type == other.type && limit == other.limit
    end

    def variable_size?
      true
    end

    private

    def initialize(type, limit)
      @type = type
      @limit = limit
    end
  end

  class List
    attr_reader :value, :type

    def <<(ele)
      raise ListTooBig unless size < limit
      raise WrongType, "#{ele.type} vs #{value_type}" unless ele.type == value_type

      @value << ele
    end

    def value_type
      @type.type
    end

    def limit
      @type.limit
    end

    def size
      @value.size
    end

    def variable_size?
      @type.variable_size?
    end

    private

    def initialize(type, value)
      @type = type

      raise ListTooBig unless value.size <= @type.limit
      raise WrongType, "#{ele.type} vs #{@type.type}" unless value.all? { |ele| ele.type == @type.type }

      @value = value
    end
  end

  class Container
    @_fields = []

    def self.fields(fields)
      @_fields = fields
      @_fields.each { |field| attr_writer field[0] }
      @_fields
    end

    class << self
      attr_reader :_fields
    end

    def fields
      self.class._fields
    end

    def values
      fields.collect { |field| instance_variable_get("@#{field[0]}") }
    end

    def value(field)
      instance_variable_get("@#{field[0]}")
    end

    def type
      self.class
    end

    def self.variable_size?
      _fields.any? { |field| field[1].variable_size? }
    end

    def variable_size?
      self.class.variable_size?
    end

    private

    def initialize(*values)
      raise InsufficientArguments unless fields.size == values.size

      fields.each.with_index do |field, i|
        raise WrongType, "#{values[i].type} vs #{field[1]}" unless values[i].nil? || values[i].type == field[1]

        instance_variable_set("@#{field[0]}", values[i])
      end
    end
  end

  class Marshal
    class << self
      def dump(obj)
        if obj.nil?
          dump_nil
        elsif obj.is_a?(Boolean)
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
        elsif obj.is_a?(Vector)
          dump_vector(obj)
        elsif obj.is_a?(List)
          dump_list(obj)
        elsif obj.is_a?(Container)
          dump_container(obj)
        else
          ''
        end
      end

      private

      def dump_nil
        ''
      end

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

      def dump_vector(vector)
        vector.value.inject('') { |str, v| str + dump(v) }
      end

      def dump_list(list)
        list.value.inject('') { |str, v| str + dump(v) }
      end

      def dump_container(container)
        if container.variable_size?
          fixed_parts =
            container.fields.collect { |field| field[1].variable_size? ? :offset : dump(container.value(field)) }
          variable_parts =
            container.fields.collect { |field| field[1].variable_size? ? dump(container.value(field)) : '' }

          fixed_lengths = fixed_parts.collect { |part| part == :offset ? BYTES_PER_LENGTH_OFFSET : part.bytes.size }
          variable_lengths = variable_parts.collect { |part| part.bytes.size }

          fixed_parts =
            fixed_parts.collect.with_index do |part, i|
              part == :offset ? dump(Uint32.new((fixed_lengths + variable_lengths[0...i]).sum)) : part
            end

          (fixed_parts + variable_parts).join('')
        else
          container.values.inject('') { |str, v| str + dump(v) }
        end
      end
    end
  end
end
