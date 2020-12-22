# frozen_string_literal: true

require_relative 'slowssz/version'

module Slowssz
  class WrongType < StandardError; end
  class IncorrectSize < StandardError; end
  class ListTooBig < StandardError; end
  class InsufficientArguments < StandardError; end
  class UnknownType < StandardError; end
  class VariableSize < StandardError; end

  BYTES_PER_LENGTH_OFFSET = 4

  class Uint8
    attr_reader :value

    def type
      Uint8
    end

    def self.length
      1
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      value == other.value
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

    def self.length
      2
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      value == other.value
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

    def self.length
      4
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      value == other.value
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

    def self.length
      8
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      value == other.value
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

    def self.length
      1
    end

    def self.variable_size?
      false
    end

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      value == other.value
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

    def ==(other)
      value == other.value
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

    def ==(other)
      value == other.value
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

    def ele_type
      type
    end

    def ==(other)
      type == other.type && size == other.size
    end

    def variable_size?
      @type.variable_size?
    end

    def ele_variable_size?
      @type.variable_size?
    end

    def length
      raise VariableSize if variable_size?

      type.length * size
    end

    private

    def initialize(type, size)
      @type = type
      @size = size
    end
  end

  class Vector
    attr_reader :value, :type

    def ele_type
      @type.type
    end

    def size
      @type.size
    end

    def variable_size?
      @type.variable_size?
    end

    def ele_variable_size?
      @type.ele_variable_size?
    end

    def ==(other)
      value == other.value
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

    def ele_type
      type
    end

    def ==(other)
      type == other.type && limit == other.limit
    end

    def variable_size?
      true
    end

    def ele_variable_size?
      @type.variable_size?
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
      raise WrongType, "#{ele.type} vs #{ele_type}" unless ele.type == ele_type

      @value << ele
    end

    def ele_type
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

    def ele_variable_size?
      @type.ele_variable_size?
    end

    def ==(other)
      value == other.value
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

      def variable_size?
        _fields.any? { |field| field[1].variable_size? }
      end

      def length
        raise VariableSize if variable_size?

        _fields.sum { |field| field[1].length }
      end
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

    def variable_size?
      self.class.variable_size?
    end

    def ==(other)
      values == other.values
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

      def restore(bytes, type)
        if type.is_a?(VectorType)
          restore_vector(bytes, type)
        elsif type.is_a?(ListType)
          restore_list(bytes, type)
        elsif type.is_a?(BitVectorType)
          restore_bit_vector(bytes, type)
        elsif type.is_a?(BitListType)
          restore_bit_list(bytes, type)
        elsif type <= Container
          restore_container(bytes, type)
        elsif type == Boolean
          restore_bool(bytes)
        elsif type == Uint8
          restore_uint8(bytes)
        elsif type == Uint16
          restore_uint16(bytes)
        elsif type == Uint32
          restore_uint32(bytes)
        elsif type == Uint64
          restore_uint64(bytes)
        else
          raise UnknownType
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
        if vector.ele_variable_size?
          variable_parts = vector.value.collect { |ele| dump(ele) }

          fixed_length = BYTES_PER_LENGTH_OFFSET * vector.size
          variable_lengths = variable_parts.collect { |part| part.bytes.size }

          fixed_parts =
            variable_parts.collect.with_index do |_part, i|
              dump(Uint32.new(([fixed_length] + variable_lengths[0...i]).sum))
            end

          (fixed_parts + variable_parts).join('')
        else
          vector.value.inject('') { |str, v| str + dump(v) }
        end
      end

      def dump_list(list)
        if list.ele_variable_size?
          variable_parts = list.value.collect { |ele| dump(ele) }

          fixed_length = BYTES_PER_LENGTH_OFFSET * list.size
          variable_lengths = variable_parts.collect { |part| part.bytes.size }

          fixed_parts =
            variable_parts.collect.with_index do |_part, i|
              dump(Uint32.new(([fixed_length] + variable_lengths[0...i]).sum))
            end

          (fixed_parts + variable_parts).join('')
        else
          list.value.inject('') { |str, v| str + dump(v) }
        end
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

      def restore_bool(bytes)
        Boolean.new(bytes.unpack1('b') == '1')
      end

      def restore_bit_vector(bytes, type)
        decoded = bytes.unpack1('b*').split('')
        raise IncorrectSize if decoded.size < type.size

        type.new(decoded[0...type.size].collect { |ele| ele == '1' })
      end

      def restore_bit_list(bytes, type)
        decoded = bytes.unpack1('b*').split('')

        # Index of last set bit (== '1') = the length of the list
        length = decoded.rindex('1')
        raise ListTooBig if length > type.limit

        type.new(decoded[0...length].collect { |ele| ele == '1' })
      end

      def restore_uint8(bytes)
        Uint8.new(bytes.unpack1('C'))
      end

      def restore_uint16(bytes)
        Uint16.new(bytes.unpack1('v'))
      end

      def restore_uint32(bytes)
        Uint32.new(bytes.unpack1('V'))
      end

      def restore_uint64(bytes)
        Uint64.new(bytes.unpack1('Q<'))
      end

      def restore_vector(bytes, type)
        if type.ele_variable_size?
          raise 'TODO'
        else
          decoded = []
          length = bytes.split('').size / type.ele_type.length
          raise IncorrectSize if length != type.size

          bytes.split('').each_slice(type.ele_type.length) { |slice| decoded << restore(slice.join(''), type.ele_type) }
          type.new(decoded)
        end
      end

      def restore_list(bytes, type)
        if type.ele_variable_size?
          raise 'TODO'
        else
          decoded = []
          length = bytes.split('').size / type.ele_type.length
          raise ListTooBig if length > type.limit

          bytes.split('').each_slice(type.ele_type.length) { |slice| decoded << restore(slice.join(''), type.ele_type) }
          type.new(decoded)
        end
      end

      def restore_container(bytes, type)
        splitted = bytes.split('')
        decoded = []
        ptr = 0

        if type.variable_size?
          offsets = []
          type._fields.each do |field|
            if field[1].variable_size?
              offsets << restore(splitted[ptr...(ptr + BYTES_PER_LENGTH_OFFSET)].join(''), Uint32)
              decoded << nil
              ptr += BYTES_PER_LENGTH_OFFSET
            else
              decoded << restore(splitted[ptr...(ptr + field[1].length)].join(''), field[1])
              ptr += field[1].length
            end
          end

          offsets << Uint32.new(splitted.length)
          offset_ptr = 0

          decoded.each.with_index do |d, i|
            if d.nil? && offsets[offset_ptr] != offsets[offset_ptr + 1]
              decoded[i] =
                restore(
                  splitted[offsets[offset_ptr].value...offsets[offset_ptr + 1].value].join(''),
                  type._fields[i][1]
                )
              offset_ptr += 1
            end
          end
        else
          type._fields.each do |field|
            decoded << restore(splitted[ptr...(ptr + field[1].length)].join(''), field[1])
            ptr += field[1].length
          end
        end

        type.new(*decoded)
      end
    end
  end
end
