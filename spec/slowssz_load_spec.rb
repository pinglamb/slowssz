# frozen_string_literal: true

def new_bit_vector_from_bytes(size, bytes, bits)
  Slowssz::BitVectorType
    .of(size: size)
    .new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' } + bits)
end

def new_bit_list_from_bytes(limit, bytes, bits)
  Slowssz::BitListType
    .of(limit: limit)
    .new([bytes].pack('H*').unpack1('b*').split('').collect { |bool| bool == '1' } + bits)
end

RSpec.describe Slowssz do
  describe '.restore' do
    it 'bool F' do
      expect(Slowssz::Marshal.restore(['00'].pack('H*'), Slowssz::Boolean)).to eq(Slowssz::Boolean.new(false))
    end

    it 'bool T' do
      expect(Slowssz::Marshal.restore(['01'].pack('H*'), Slowssz::Boolean)).to eq(Slowssz::Boolean.new(true))
    end

    it 'bitvector TTFTFTFF' do
      expect(Slowssz::Marshal.restore(['2b'].pack('H*'), Slowssz::BitVectorType.of(size: 8))).to eq(
        Slowssz::BitVectorType.of(size: 8).new([true, true, false, true, false, true, false, false])
      )
    end

    it 'bitlist TTFTFTFF' do
      expect(Slowssz::Marshal.restore(['2b01'].pack('H*'), Slowssz::BitListType.of(limit: 8))).to eq(
        Slowssz::BitListType.of(limit: 8).new([true, true, false, true, false, true, false, false])
      )
    end

    it 'bitvector FTFT' do
      expect(Slowssz::Marshal.restore(['0a'].pack('H*'), Slowssz::BitVectorType.of(size: 4))).to eq(
        Slowssz::BitVectorType.of(size: 4).new([false, true, false, true])
      )
    end

    it 'bitlist FTFT' do
      expect(Slowssz::Marshal.restore(['1a'].pack('H*'), Slowssz::BitListType.of(limit: 4))).to eq(
        Slowssz::BitListType.of(limit: 4).new([false, true, false, true])
      )
    end

    it 'bitvector FTF' do
      expect(Slowssz::Marshal.restore(['02'].pack('H*'), Slowssz::BitVectorType.of(size: 3))).to eq(
        Slowssz::BitVectorType.of(size: 3).new([false, true, false])
      )
    end

    it 'bitlist FTF' do
      expect(Slowssz::Marshal.restore(['0a'].pack('H*'), Slowssz::BitListType.of(limit: 4))).to eq(
        Slowssz::BitListType.of(limit: 4).new([false, true, false])
      )
    end

    it 'bitvector TFTFFFTTFT' do
      expect(Slowssz::Marshal.restore(['c502'].pack('H*'), Slowssz::BitVectorType.of(size: 10))).to eq(
        Slowssz::BitVectorType.of(size: 10).new([true, false, true, false, false, false, true, true, false, true])
      )
    end

    it 'bitlist TFTFFFTTFT' do
      expect(Slowssz::Marshal.restore(['c506'].pack('H*'), Slowssz::BitListType.of(limit: 10))).to eq(
        Slowssz::BitListType.of(limit: 10).new([true, false, true, false, false, false, true, true, false, true])
      )
    end

    it 'bitvector TFTFFFTTFTFFFFTT' do
      expect(Slowssz::Marshal.restore(['c5c2'].pack('H*'), Slowssz::BitVectorType.of(size: 16))).to eq(
        Slowssz::BitVectorType
          .of(size: 16)
          .new(
            [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true]
          )
      )
    end

    it 'bitlist TFTFFFTTFTFFFFTT' do
      expect(Slowssz::Marshal.restore(['c5c201'].pack('H*'), Slowssz::BitListType.of(limit: 16))).to eq(
        Slowssz::BitListType
          .of(limit: 16)
          .new(
            [true, false, true, false, false, false, true, true, false, true, false, false, false, false, true, true]
          )
      )
    end

    it 'long bitvector' do
      expect(Slowssz::Marshal.restore(['ff' * 64].pack('H*'), Slowssz::BitVectorType.of(size: 512))).to eq(
        new_bit_vector_from_bytes(512, 'ff' * 64, [])
      )
    end

    it 'long bitlist' do
      expect(Slowssz::Marshal.restore(['07'].pack('H*'), Slowssz::BitListType.of(limit: 512))).to eq(
        Slowssz::BitListType.of(limit: 512).new([true, true])
      )
    end

    it 'long bitlist filled' do
      expect(Slowssz::Marshal.restore(['ff' * 64 + '01'].pack('H*'), Slowssz::BitListType.of(limit: 512))).to eq(
        new_bit_list_from_bytes(512, 'ff' * 64, [])
      )
    end

    it 'odd bitvector filled' do
      expect(Slowssz::Marshal.restore(['ff' * 64 + '01'].pack('H*'), Slowssz::BitVectorType.of(size: 513))).to eq(
        new_bit_vector_from_bytes(513, 'ff' * 64, [true])
      )
    end

    it 'odd bitlist filled' do
      expect(Slowssz::Marshal.restore(['ff' * 64 + '03'].pack('H*'), Slowssz::BitListType.of(limit: 513))).to eq(
        new_bit_list_from_bytes(513, 'ff' * 64, [true])
      )
    end

    it 'uint8 00' do
      expect(Slowssz::Marshal.restore(['00'].pack('H*'), Slowssz::Uint8)).to eq(Slowssz::Uint8.new(0x00))
    end

    it 'uint8 01' do
      expect(Slowssz::Marshal.restore(['01'].pack('H*'), Slowssz::Uint8)).to eq(Slowssz::Uint8.new(0x01))
    end

    it 'uint8 ab' do
      expect(Slowssz::Marshal.restore(['ab'].pack('H*'), Slowssz::Uint8)).to eq(Slowssz::Uint8.new(0xab))
    end

    it 'uint16 0000' do
      expect(Slowssz::Marshal.restore(['0000'].pack('H*'), Slowssz::Uint16)).to eq(Slowssz::Uint16.new(0x0000))
    end

    it 'uint16 abcd' do
      expect(Slowssz::Marshal.restore(['cdab'].pack('H*'), Slowssz::Uint16)).to eq(Slowssz::Uint16.new(0xabcd))
    end

    it 'uint32 00000000' do
      expect(Slowssz::Marshal.restore(['00000000'].pack('H*'), Slowssz::Uint32)).to eq(Slowssz::Uint32.new(0x00000000))
    end

    it 'uint32 01234567' do
      expect(Slowssz::Marshal.restore(['67452301'].pack('H*'), Slowssz::Uint32)).to eq(Slowssz::Uint32.new(0x01234567))
    end

    it 'uint64 0000000000000000' do
      expect(Slowssz::Marshal.restore(['0000000000000000'].pack('H*'), Slowssz::Uint64)).to eq(
        Slowssz::Uint64.new(0x0000000000000000)
      )
    end

    it 'uint64 0123456789abcdef' do
      expect(Slowssz::Marshal.restore(['efcdab8967452301'].pack('H*'), Slowssz::Uint64)).to eq(
        Slowssz::Uint64.new(0x0123456789abcdef)
      )
    end

    it 'uint16 list' do
      expect(
        Slowssz::Marshal.restore(['bbaaadc0ffee'].pack('H*'), Slowssz::ListType.of(type: Slowssz::Uint16, limit: 32))
      ).to eq(
        Slowssz::ListType
          .of(type: Slowssz::Uint16, limit: 32)
          .new([Slowssz::Uint16.new(0xaabb), Slowssz::Uint16.new(0xc0ad), Slowssz::Uint16.new(0xeeff)])
      )
    end

    it 'uint32 list' do
      expect(
        Slowssz::Marshal.restore(
          ['bbaa0000adc00000ffee0000'].pack('H*'),
          Slowssz::ListType.of(type: Slowssz::Uint32, limit: 128)
        )
      ).to eq(
        Slowssz::ListType
          .of(type: Slowssz::Uint32, limit: 128)
          .new([Slowssz::Uint32.new(0xaabb), Slowssz::Uint32.new(0xc0ad), Slowssz::Uint32.new(0xeeff)])
      )
    end

    it 'bytes32 list' do
      expect(
        Slowssz::Marshal.restore(
          [
            'bbaa000000000000000000000000000000000000000000000000000000000000' +
              'adc0000000000000000000000000000000000000000000000000000000000000' +
              'ffee000000000000000000000000000000000000000000000000000000000000'
          ].pack('H*'),
          Slowssz::ListType.of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 64)
        )
      ).to eq(
        Slowssz::ListType
          .of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 64)
          .new(
            [
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xbb), Slowssz::Uint8.new(0xaa)] + [Slowssz::Uint8.new(0x00)] * 30),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xad), Slowssz::Uint8.new(0xc0)] + [Slowssz::Uint8.new(0x00)] * 30),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(0xff), Slowssz::Uint8.new(0xee)] + [Slowssz::Uint8.new(0x00)] * 30)
            ]
          )
      )
    end

    it 'bytes32 list long' do
      expect(
        Slowssz::Marshal.restore(
          [
            '0100000000000000000000000000000000000000000000000000000000000000' +
              '0200000000000000000000000000000000000000000000000000000000000000' +
              '0300000000000000000000000000000000000000000000000000000000000000' +
              '0400000000000000000000000000000000000000000000000000000000000000' +
              '0500000000000000000000000000000000000000000000000000000000000000' +
              '0600000000000000000000000000000000000000000000000000000000000000' +
              '0700000000000000000000000000000000000000000000000000000000000000' +
              '0800000000000000000000000000000000000000000000000000000000000000' +
              '0900000000000000000000000000000000000000000000000000000000000000' +
              '0a00000000000000000000000000000000000000000000000000000000000000' +
              '0b00000000000000000000000000000000000000000000000000000000000000' +
              '0c00000000000000000000000000000000000000000000000000000000000000' +
              '0d00000000000000000000000000000000000000000000000000000000000000' +
              '0e00000000000000000000000000000000000000000000000000000000000000' +
              '0f00000000000000000000000000000000000000000000000000000000000000' +
              '1000000000000000000000000000000000000000000000000000000000000000' +
              '1100000000000000000000000000000000000000000000000000000000000000' +
              '1200000000000000000000000000000000000000000000000000000000000000' +
              '1300000000000000000000000000000000000000000000000000000000000000'
          ].pack('H*'),
          Slowssz::ListType.of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 128)
        )
      ).to eq(
        Slowssz::ListType
          .of(type: Slowssz::VectorType.of(type: Slowssz::Uint8, size: 32), limit: 128)
          .new(
            [
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(1)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(2)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(3)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(4)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(5)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(6)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(7)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(8)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(9)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(10)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(11)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(12)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(13)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(14)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(15)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(16)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(17)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(18)] + [Slowssz::Uint8.new(0x00)] * 31),
              Slowssz::VectorType
                .of(type: Slowssz::Uint8, size: 32)
                .new([Slowssz::Uint8.new(19)] + [Slowssz::Uint8.new(0x00)] * 31)
            ]
          )
      )
    end
  end
end
